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

  lazy private var recentFoodRecords: [IBSRecord] = recentRecords(of: .food)

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
  func isAvailable(timestamp: Date) -> Bool {
    do {
      let record = try appDB.selectRecord(in: SQLIBSRecord.self, at: timestamp)
      return record == nil
    } catch {
      print("Error: Couldn't select the record at [\(timestamp)]")
    }
    return false
  }

  func recentRecords(of type: ItemType, recordsToDisplay: Int = 60) -> [IBSRecord] {
    Array(recentFoodRecords.prefix(recordsToDisplay))
  }

  func reloadRecordsFromSQL() {
    allRecords = IBSData.loadRecordsFromSQL(appDB: appDB)
  }

  func tags(for type: ItemType) -> [String] {
    var tags: [SQLTagRecord?] = []
    do {
      tags = try appDB.selectRecords(in: SQLTagRecord.self, of: type)
    } catch {
      print("Error: Couldn't load records from sql: \(error)")
    }
    return tags.map { $0!.name }
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

  func recentRecords(of type: ItemType) -> [IBSRecord] {
    let preSortedTypedRecords = allRecords
      .filter { $0.type == type }
      .sorted { $0.timestamp > $1.timestamp }

    let recordsCounted = preSortedTypedRecords.reduce(into: [IBSRecord: (count: Int, record: IBSRecord)]()) {
      let key = IBSRecord(comparable: $1)
      $0[key, default: (0, $1)].count += 1
    }

    let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!

    let maxCount = recordsCounted.map { $1.count }.max() ?? 0
    let sortedRecords = recordsCounted
      .sorted {
        let lhsValue = $0.1.record.weightedValue(count: $0.1.count, maxCount: maxCount, yesterday: yesterday)
        let rhsValue = $1.1.record.weightedValue(count: $1.1.count, maxCount: maxCount, yesterday: yesterday)
        return lhsValue > rhsValue
      }

    return sortedRecords.map { $0.1.record }
  }
}
