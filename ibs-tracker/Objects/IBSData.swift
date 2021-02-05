//
//  IBSData.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

class IBSData: ObservableObject {
  @Published var dayRecords: [DayRecord] = IBSData.loadRecordsFromJSON()
}

private extension IBSData {
  static func loadRecordsFromJSON() -> [DayRecord] {
    let allRecords = Bundle.main.decode([IBSRecord].self, from: "records.json")
    let sortedRecords = allRecords.sorted { $0.timestamp > $1.timestamp }

    return groupByDay(sortedRecords)
  }

  static func groupByDay(_ sortedRecords: [IBSRecord]) -> [DayRecord] {
    guard let firstJSONRecord = sortedRecords.first else { return [] }

    var currentIBSRecords: [IBSRecord] = []
    var previousKeyString: String? = DayRecord.keyString(for: firstJSONRecord.timestamp)
    var previousKeyDate: Date?

    var dayRecords: [DayRecord] = []

    for record in sortedRecords {
      guard let keyString = DayRecord.keyString(for: record.timestamp) else { continue }
      guard let keyDate = DayRecord.keyDate(for: record.date) else { continue }

      if keyString == previousKeyString {
        currentIBSRecords.append(record)
      } else {
        if currentIBSRecords.isNotEmpty && previousKeyDate != nil {
          let dayRecord = DayRecord(date: previousKeyDate!, ibsRecords: currentIBSRecords)
          dayRecords.append(dayRecord)
        }

        currentIBSRecords = []
      }

      previousKeyString = keyString
      previousKeyDate = keyDate
    }

    return dayRecords
  }
}
