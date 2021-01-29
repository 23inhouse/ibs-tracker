//
//  SearchView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct SearchView: View {
  @EnvironmentObject private var appState: IBSData
  @State private var filter: ItemType? = nil

  var records: [DayRecord] {
    guard let filter = filter else { return appState.dayRecords }

    let dayRecords: [DayRecord?] = appState.dayRecords.map {
      let ibsRecords = $0.ibsRecords.filter {
        $0.type == filter
      }
      if ibsRecords.isNotEmpty {
        return DayRecord(date: $0.date, ibsRecords: ibsRecords)
      }
      return nil
    }
    return dayRecords.compactMap { $0 }
  }

  var body: some View {
    NavigationView {
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
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .food)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .medication)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .note)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .weight)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .mood)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .ache)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .gut)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          filterButton(for: .bm)
        }
      }
    }
  }
}

private extension SearchView {
  func filterButton(for filter: ItemType) -> some View {
    Button(action: {
      self.filter = self.filter == filter ? nil : filter
    }) {
      ToolBarFilterIconView(for: filter, filteredBy: $filter)
    }
  }
}

struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView()
      .environmentObject(IBSData())
  }
}
