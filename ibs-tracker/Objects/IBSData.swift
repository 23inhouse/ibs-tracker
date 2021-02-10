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
    do {
      let allRecords = try Bundle.main.decode([IBSRecord].self, from: "records.json")
      let sortedRecords = allRecords.sorted { $0.timestamp > $1.timestamp }

      return groupByDay(sortedRecords)
    } catch {
      print("Error: failed to load records from records.json")
    }
    return []
  }

  static func groupByDay(_ sortedRecords: [IBSRecord]) -> [DayRecord] {
    guard let firstJSONRecord = sortedRecords.first else { return [] }

    let keyStringFormat = "yyyy-MM-dd"
    var currentIBSRecords: [IBSRecord] = []
    var previousKeyString: String? = DayRecord.keyDate(for: firstJSONRecord.timestamp)?.string(for: keyStringFormat)
    var previousKeyDate: Date?

    var dayRecords: [DayRecord] = []

    for record in sortedRecords {
      guard let keyString = DayRecord.keyDate(for: record.timestamp)?.string(for: keyStringFormat) else { continue }
      guard let keyDate = DayRecord.keyDate(for: record.timestamp) else { continue }

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
