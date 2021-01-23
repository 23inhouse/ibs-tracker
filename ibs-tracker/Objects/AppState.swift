//
//  AppState.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

class AppState: ObservableObject {
  @Published var dayRecords: [DayRecord] = AppState.loadRecords()
}

private extension AppState {
  static func loadRecords() -> [DayRecord] {
    let allRecords = Bundle.main.decode([IBSRecord].self, from: "records.json")
    let sortedRecords = allRecords.sorted { $0.timestamp > $1.timestamp }

    var records = [DayRecord]()

    var currentIBSRecords: [IBSRecord] = []
    var previousKeyString: String?

    for record in sortedRecords {
      guard let keyDate = record.keyDate() else { continue }
      let keyString = record.keyString()

      if keyString == previousKeyString {
        currentIBSRecords.append(record)
      } else {
        if currentIBSRecords.isNotEmpty {
          let dayRecord = DayRecord(date: keyDate, ibsRecords: currentIBSRecords)
          records.append(dayRecord)
        }

        currentIBSRecords = []
      }

      previousKeyString = keyString
    }

    return records
  }
}
