//
//  SearchView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct SearchView: View {
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject private var appState: IBSData
  @State private var filters: [ItemType] = []
  @State private var showFilters: Bool = false
  @State private var search: String = ""

  private var filterToggleImage: String {
    showFilters ? "line.horizontal.3.circle.fill" : "line.horizontal.3.circle"
  }

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  var body: some View {
    NavigationView {
      ZStack {
        SearchList(filters: $filters, search: $search)
        if showFilters {
          List {
            ForEach(ItemType.allCases, id: \.self) { itemType in
              Toggle(isOn: Binding(
                get: { filters.contains(itemType) },
                set: { filters.toggle(on: $0, element: itemType)}
              )) {
                HStack {
                  TypeShape(type: itemType)
                    .stroke(style: strokeStyle)
                    .foregroundColor(.secondary)
                    .frame(25)
                    .padding(5)
                  Text(itemType.rawValue.capitalized)
                }
              }
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          TextField("Search ...", text: $search)
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
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showFilters.toggle()
          } label: {
            Image(systemName: filterToggleImage)
          }
        }
      }
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView()
      .environmentObject(IBSData())
  }
}

struct SearchList: View {
  @EnvironmentObject private var appState: IBSData
  @Binding var filters: [ItemType]
  @Binding var search: String

  var records: [DayRecord] {
    guard filters.isNotEmpty || search != "" else { return appState.dayRecords }

    let dayRecords: [DayRecord?] = appState.dayRecords.map {
      let ibsRecords = $0.ibsRecords.filter {
        let content = ($0.text ?? "") + $0.tags.joined(separator: "")
        return
          (filters.isEmpty || filters.contains($0.type)) &&
          (search == "" || content.contains(search))
      }
      if ibsRecords.isNotEmpty {
        return DayRecord(date: $0.date, ibsRecords: ibsRecords)
      }
      return nil
    }
    return dayRecords.compactMap { $0 }
  }

  var body: some View {
    List {
      ForEach(records) { dayRecord in
        let dateString = dayRecord.date.string(for: "dd MMM YYYY")
        Section(header: Text(dateString)) {
          ForEach(dayRecord.ibsRecords, id: \.self) { record in
            ItemTypeDayRowView(record: record)
            .listRowInsets(EdgeInsets())
          }
        }
      }
    }
    .id(UUID())
  }
}
