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
  case chart
  case settings
}

class IBSData: ObservableObject {
  @Published var tabSelection: Tabs = .add
  @Published var activeChart: Charts = .symptoms
  @Published var dayRecords: [DayRecord]
  @Published var lastWeight: Decimal
  @Published var activeDate: Date
  @Published var computedRecords: [IBSRecord]

  static let numberOfHoursInMorningIncludedInPreviousDay = 4 // up to 4am
  static var current = IBSData(appDB: .current)

  private var savedRecords: [IBSRecord] {
    didSet {
      self.dayRecords = IBSData.groupByDay(savedRecords)
      self.lastWeight = IBSData.lastWeight(savedRecords)
      self.computedRecords = savedRecords.reversed()
    }
  }

  private var appDB: AppDB

  init(appDB: AppDB) {
    guard !(ibs_trackerApp.isTestRunning() && appDB != .test) else {
      fatalError("FAILURE: IBSData must be set to .test mode while the tests are running")
    }
    self.appDB = appDB
    self.activeDate = IBSData.timeShiftedDate()
    self.savedRecords = []
    self.dayRecords = []
    self.lastWeight = 0
    self.computedRecords = []
  }

  init(_ ibsRecords: [IBSRecord] = []) {
    self.appDB = .test
    self.activeDate = IBSData.timeShiftedDate()
    self.savedRecords = ibsRecords
    self.dayRecords = IBSData.groupByDay(savedRecords)
    self.lastWeight = IBSData.lastWeight(savedRecords)
    self.computedRecords = savedRecords.reversed()
  }

  func loadData() {
    self.savedRecords = IBSData.loadRecordsFromSQL(appDB: appDB)
  }
}

extension IBSData {
  // currentDate moves records before 5am to the previous day
  // So a record at 2am will be display after the 11pm records
  // In the context of food and IBS 5am is the start of a new day
  static func timeShiftedDate(for date: Date = Date()) -> Date {
    Calendar.current.date(byAdding: .hour, value: -numberOfHoursInMorningIncludedInPreviousDay, to: date) ?? date
  }

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
    Array(recentRecords(of: type).prefix(recordsToDisplay))
  }

  func reloadRecordsFromSQL() {
    savedRecords = IBSData.loadRecordsFromSQL(appDB: appDB)
  }

  func tags(for type: ItemType) -> [String] {
    var tags: [SQLTagRecord?] = []
    do {
      tags = try appDB.tags(of: type)
    } catch {
      print("Error: Couldn't load records from sql: \(error)")
    }

    return tags.map { $0!.name }
  }
}

private extension IBSData {
  static func groupByDay(_ records: [IBSRecord]) -> [DayRecord] {
    let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }

    guard sortedRecords.count > 0 else { return [] }

    let keyStringFormat = "yyyy-MM-dd"
    let count = sortedRecords.count
    var i = 0
    var dayRecords: [DayRecord] = []
    var currentIBSRecords: [IBSRecord] = []
    var previousKeyString: String?
    var previousKeyDate: Date?

    repeat {
      let record = sortedRecords[i]
      i += 1

      let keyString = timeShiftedDate(for: record.timestamp).string(for: keyStringFormat)
      let keyDate = timeShiftedDate(for: record.timestamp)

      if keyString != previousKeyString {
        if currentIBSRecords.isNotEmpty, let prevKeyDate: Date = previousKeyDate {
          let dayRecord = DayRecord(date: prevKeyDate, ibsRecords: currentIBSRecords)
          dayRecords.append(dayRecord)
        }

        currentIBSRecords = []
      }

      currentIBSRecords.append(record)

      previousKeyString = keyString
      previousKeyDate = keyDate
    } while i < count

    if currentIBSRecords.isNotEmpty, let prevKeyDate: Date = previousKeyDate {
      let dayRecord = DayRecord(date: prevKeyDate, ibsRecords: currentIBSRecords)
      dayRecords.append(dayRecord)
    }

    return dayRecords
  }

  static func lastWeight(_ records: [IBSRecord]) -> Decimal {
    records
      .filter { $0.type == .weight }
      .sorted { $0.timestamp < $1.timestamp }
      .last?.weight ?? 0
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
    let preSortedTypedRecords = savedRecords
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
