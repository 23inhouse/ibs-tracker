//
//  IBSData.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

enum Tabs {
  case day
  case search
  case add
  case report
  case settings
}

class IBSData: ObservableObject {
  @Published var tabSelection: Tabs = .day
  @Published var dayRecords: [DayRecord]

  static var current = IBSData(.current)

  private var allRecords: [IBSRecord] {
    didSet {
      self.dayRecords = IBSData.groupByDay(allRecords)
    }
  }

  private var appDB: AppDB

  init(_ appDB: AppDB = .current) {
    guard !(ibs_trackerApp.isTestRunning() && appDB != .test) else {
      fatalError("FAILURE: IBSData must be set to .test mode while the tests are running")
    }
    self.appDB = appDB
    self.allRecords = IBSData.loadRecordsFromSQL(appDB: appDB)
    self.dayRecords = IBSData.groupByDay(allRecords)
  }
}

extension IBSData {
  static func loadRecordsFromSQL() -> [IBSRecord] {
    do {
      return try AppDB.current.exportRecords()
    } catch {
      print("Error: Couldn't load records from sql: \(error)")
    }
    return []
  }

  func recent(_ type: ItemType, recordsToDisplay: Int = 60) -> [IBSRecord] {
    let preSortedTypedRecords = allRecords
      .filter { $0.type == type }
      .sorted { $0.timestamp > $1.timestamp }

    let recordsCounted = preSortedTypedRecords.reduce(into: [IBSRecord: Int]()) {
      $0[$1, default: 0] += 1
    }

    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    let secondsPerDay: Double = 86400

    func weightedValue(record: IBSRecord, count: Int, maxCount: Int) -> Int {
      let interval: TimeInterval = yesterday.timeIntervalSinceReferenceDate - record.timestamp.timeIntervalSinceReferenceDate
      let daysSince = Int(interval / secondsPerDay)

      let daysOfInterest = 42 // any records in the last 42 days

      let factor = Double(daysOfInterest * daysOfInterest)
      var value: Int = 0
      value += Int(factor - Double(daysSince * daysSince)) // curved so value decreases rapidly as with age aproaching daysOfInterest
      value += Int(Double(count).squareRoot() / Double(maxCount).squareRoot() * factor / 2) // curved so values decrease slowly as the count decreases
      return value
    }

    let maxCount = recordsCounted.map { $1 }.max() ?? 0
    let sortedRecords = recordsCounted
      .sorted {
        let lhsValue = weightedValue(record: $0.0, count: $0.1, maxCount: maxCount)
        let rhsValue = weightedValue(record: $1.0, count: $1.1, maxCount: maxCount)
        return lhsValue > rhsValue
      }

    let topResults = sortedRecords
      .map { $0.0 }.prefix(recordsToDisplay)

    return Array(topResults)
  }

  func reloadRecordsFromSQL() {
    allRecords = IBSData.loadRecordsFromSQL(appDB: appDB)
  }
}

private extension IBSData {
  static func groupByDay(_ records: [IBSRecord]) -> [DayRecord] {
    let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }

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

  static func loadRecordsFromSQL(appDB: AppDB) -> [IBSRecord] {
    do {
      return try appDB.exportRecords()
    } catch {
      print("Error: Couldn't load records from sql: \(error)")
    }
    return []
  }
}
