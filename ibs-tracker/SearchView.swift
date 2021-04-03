//
//  SearchView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct SearchView: View {
  @State private var filters: [ItemType] = []
  @State private var showFilters: Bool = false
  @State private var search: String = ""

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  var body: some View {
    NavigationView {
      ZStack {
        SearchList(search: $search, filters: $filters)
        if showFilters {
          filtersList
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          SearchField(search: $search)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          toggleFilters
        }
      }
    }
    .gesture(DragGesture().onChanged { _ in endEditing(true) })
  }

  private var filtersList: some View {
    List {
      ForEach(ItemType.allCases, id: \.self) { itemType in
        Toggle(isOn: Binding(
          get: { filters.contains(itemType) },
          set: { filters.toggle(on: $0, element: itemType) }
        )) {
          HStack {
            TypeShape(type: itemType)
              .stroke(style: strokeStyle)
              .foregroundColor(.secondary)
              .frame(25)
              .padding(5)
            Text(itemType.rawValue.capitalized)
            Spacer()
          }
          .contentShape(Rectangle())
          .onTapGesture {
            withAnimation {
              filters.toggle(on: !filters.contains(itemType), element: itemType)
            }
          }
        }
      }
    }
    .gesture(DragGesture().onChanged { value in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        showFilters.toggle()
      }
    })
  }

  private var toggleFilters: some View {
    Button {
      showFilters.toggle()
    } label: {
      Image(systemName: "slider.horizontal.3")
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView()
      .environmentObject(IBSData())
  }
}

struct SearchField: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var search: String

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  var body: some View {
    return TextField("Search ...", text: $search)
      .padding(5)
      .padding(.leading, 20)
      .frame(width: 300)
      .backgroundColor(backgroundColor)
      .cornerRadius(8)
      .overlay(
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 4)

        })
  }
}

struct SearchList: View {
  @EnvironmentObject private var appState: IBSData

  @State var records: [DayRecord] = []

  @Binding var search: String
  @Binding var filters: [ItemType]

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(records) { dayRecord in
          Text(dayRecord.date.string(for: "EEEE - dd MMMM YYYY"))
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(
              Color.secondary
                .opacity(0.5)
                .cornerRadius(radius: 20, corners: [.topLeft, .topRight])
            )
            .padding(.horizontal, 10)
            .padding(.top, 10)
          ForEach(dayRecord.ibsRecords, id: \.self) { record in
            ItemTypeDayRowView(record: record)
            Divider()
              .padding(.horizontal, 10)
          }
        }
      }
    }
    .onAppear() { calcRecords() }
    .onChange(of: search)  { _ in calcRecords() }
    .onChange(of: filters)  { _ in calcRecords() }
  }
}

private extension SearchList {
  func calcRecords() {
    guard filters.isNotEmpty || search != "" else {
      records = appState.dayRecords
      return
    }

    DispatchQueue.main.async {
      let searchQuery = search.lowercased()
      let dayRecords: [DayRecord?] = appState.dayRecords.map {
        let ibsRecords = $0.ibsRecords.filter {
          let content = (($0.text ?? "") + $0.tags.joined(separator: "")).lowercased()
          return
            (filters.isEmpty || filters.contains($0.type)) &&
            (searchQuery == "" || content.contains(searchQuery))
        }
        if ibsRecords.isNotEmpty {
          return DayRecord(date: $0.date, ibsRecords: ibsRecords)
        }
        return nil
      }

      records = dayRecords.compactMap { $0 }
    }
  }
}
