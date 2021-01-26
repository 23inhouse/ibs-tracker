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
          Button(action: {
            filter = filter == .food ? nil : .food
          }) {
            ToolBarFilterIconView(for: .food, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .medication ? nil : .medication
          }) {
            ToolBarFilterIconView(for: .medication, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .note ? nil : .note
          }) {
            ToolBarFilterIconView(for: .note, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .weight ? nil : .weight
          }) {
            ToolBarFilterIconView(for: .weight, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .mood ? nil : .mood
          }) {
            ToolBarFilterIconView(for: .mood, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .ache ? nil : .ache
          }) {
            ToolBarFilterIconView(for: .ache, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .gut ? nil : .gut
          }) {
            ToolBarFilterIconView(for: .gut, filteredBy: $filter)
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            filter = filter == .bm ? nil : .bm
          }) {
            ToolBarFilterIconView(for: .bm, filteredBy: $filter)
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
