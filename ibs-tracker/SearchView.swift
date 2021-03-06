//
//  SearchView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct SearchView: View {
  @EnvironmentObject private var appState: IBSData

  @State private var filterSummary: Bool = false
  @State private var filters: [ItemType] = []
  @State private var filterOffset: CGSize = CGSize(UIScreen.mainWidth, 0)
  @State private var showFilters: Bool = false
  @State private var search: String = ""

  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        ZStack {
          SearchList(search: $search, filterSummary: $filterSummary, filters: $filters)
          FilterList(filterSummary: $filterSummary, filters: $filters)
            .offset(filterOffset)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            SearchField(search: $search)
              .frame(width: (geometry.width > 210 ? geometry.width - 70 : 260))
          }
          ToolbarItem(placement: .navigationBarTrailing) {
            toggleFiltersButton
          }
        }
      }
    }
    .gesture(swipeFilterGesture)
    .simultaneousGesture(clearKeyboardGesture)
  }

  private var swipeFilterGesture: some Gesture {
    DragGesture()
      .onChanged { gesture in
        let offset = filterOffset.width
        let translation = gesture.translation.width
        let xAnchor = showFilters ? 0 : UIScreen.mainWidth

        guard offset >= 0 && offset <= UIScreen.mainWidth else { return }

        filterOffset.width = xAnchor + translation
        filterOffset.height = 0
      }.onEnded { _ in
        let margin: CGFloat = UIScreen.mainWidth / 4.5
        let offset = filterOffset.width

        if !showFilters && offset > UIScreen.mainWidth - margin {
          showFilters.toggle()
        }
        else if showFilters && offset < margin {
          showFilters.toggle()
        }

        DispatchQueue.main.async { toggleFilter() }
      }
  }

  private var clearKeyboardGesture: _ChangedGesture<DragGesture> {
    DragGesture().onChanged { _ in endEditing(true) }
  }

  private var swipeFilterAwayGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
    DragGesture()
      .onChanged { gesture in
        guard gesture.translation.width > 0 else { return }

        filterOffset.width = gesture.translation.width
        filterOffset.height = 0
      }.onEnded { _ in
        DispatchQueue.main.async {
          if filterOffset.width > 100 {
            toggleFilter()
          } else {
            filterOffset.width = 0
          }
        }
      }
  }

  private var toggleFiltersButton: some View {
    Button {
      toggleFilter()
    } label: {
      Image(systemName: "slider.horizontal.3")
    }
  }

  private func toggleFilter() {
    withAnimation {
      showFilters.toggle()
      let x = showFilters ? 0 : UIScreen.mainWidth
      filterOffset = CGSize(x, 0)
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView()
      .environmentObject(IBSData([IBSRecord(timestamp: Date(), condition: .mild)]))
  }
}

struct SearchList: View {
  @Environment(\.colorScheme) var colorScheme
  @EnvironmentObject private var appState: IBSData

  @State var records: [DayRecord] = []
  @State private var searchFilterWorkItem: DispatchWorkItem?

  @Binding var search: String
  @Binding var filterSummary: Bool
  @Binding var filters: [ItemType]

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        if search.isNotEmpty {
          Text("Showing \(records.count) records")
            .padding(.vertical, 10)
          Divider()
            .padding(.horizontal, 10)
        }
        ForEach(records) { dayRecord in
          Button(dayRecord.date.string(for: "dd MMMM YYYY - EEEE")) {
            DispatchQueue.main.async {
              appState.tabSelection = .day
              withAnimation {
                appState.activeDate = dayRecord.date
              }
            }
          }
          .foregroundColor(colorScheme == .dark ? .black : .white)
          .frame(maxWidth: .infinity, alignment: .center)
          .contentShape(Rectangle())
          .padding(3)
          .backgroundColor(.blue)

          if filterSummary == true || filters.isEmpty {
            if dayRecord.records.filter(\.isSummary).isNotEmpty {
              SummaryRowView(dayRecord, filters: filters)
              Divider()
                .padding(.horizontal, 10)
            }
          }

          if filterSummary != true || filters.isNotEmpty {
            ForEach(dayRecord.records, id: \.self) { record in
              ItemTypeDayRowView(record: record)
              Divider()
                .padding(.horizontal, 10)
            }
          }

          Spacer()
            .frame(height: 30)
        }
      }
    }
    .onAppear { calcRecords() }
    .onChange(of: search)  { _ in calcRecords() }
    .onChange(of: filters)  { _ in calcRecords() }
    .onChange(of: appState.savedRecords)  { _ in calcRecords() }
  }
}

private extension SearchList {
  func calcRecords() {
    guard filters.isNotEmpty || search != "" else {
      records = appState.recordsByDay
      return
    }

    searchFilterWorkItem?.cancel()

    let currentWorkItem = DispatchWorkItem {
      let searchQuery = search.lowercased()
      let searchTerms = searchQuery.parseTokens()

      let recordsByDay: [DayRecord?] = appState.recordsByDay.map { dayRecord in
        let records = dayRecord.records.filter { record in
          let content = record.metaTags.joined(separator: "").lowercased()
          return
            (filters.isEmpty || filters.contains(record.type)) &&
            (searchQuery == "" || searchTerms.first(where: { content.contains($0) }) != nil)
        }
        if records.isNotEmpty {
          return DayRecord(date: dayRecord.date, records: records, unfilteredRecords: dayRecord.records, calculateMeta: false)
        }
        return nil
      }

      records = recordsByDay.compactMap { $0 }
    }

    let delay = 0.666
    searchFilterWorkItem = currentWorkItem
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: currentWorkItem)
  }
}

struct FilterList: View {
  @Environment(\.colorScheme) var colorScheme

  @Binding var filterSummary: Bool
  @Binding var filters: [ItemType]

  private let allCases: [ItemType] = ItemType.allCases.filter { $0 != .none }
  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  var body: some View {
    VStack {
      HStack {
        Toggle(isOn: $filterSummary) {
          Image(systemName: "circle.grid.2x2")
          Text("Summary")
          Spacer()
        }
      }
      .padding(.horizontal, 10)
      Divider()
      ForEach(allCases, id: \.self) { itemType in
        HStack {
          Toggle(isOn: Binding(
            get: { filters.contains(itemType) },
            set: { filters.toggle(on: $0, element: itemType) }
          )) {
            TypeShape(type: itemType)
              .stroke(style: strokeStyle)
              .foregroundColor(.secondary)
              .frame(25)
            Text(itemType.rawValue.capitalized)
            Spacer()
          }
        }
        .padding(.horizontal, 10)
        Divider()
      }
      Spacer()
    }
    .padding(.top, 10)
    .backgroundColor(colorScheme == .dark ? .black : .white)
  }
}
