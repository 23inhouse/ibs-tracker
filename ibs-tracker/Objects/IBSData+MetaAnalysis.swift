//
//  IBSData+MetaAnalysis.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 20/4/21.
//

import Foundation

protocol MetaAnalysis {
  var computedRecords: [IBSRecord] { get }
  var recordsByDay: [DayRecord] { get }
  static func computeAnalysedRecords(_ records: [IBSRecord]) -> ([DayRecord], [IBSRecord])
}

extension IBSData: MetaAnalysis {
  static func computeAnalysedRecords(_ records: [IBSRecord]) -> ([DayRecord], [IBSRecord]) {
    var recordsByDay: [DayRecord] = []
    var computedRecords: [IBSRecord] = []

    computedRecords = records.reversed()

    let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }

    guard sortedRecords.count > 0 else { return ([], []) }

    let keyStringFormat = "yyyy-MM-dd"
    let count = sortedRecords.count
    var i = 0
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
          recordsByDay.append(dayRecord)
        }

        currentIBSRecords = []
      }

      currentIBSRecords.append(record)

      previousKeyString = keyString
      previousKeyDate = keyDate
    } while i < count

    if currentIBSRecords.isNotEmpty, let prevKeyDate: Date = previousKeyDate {
      let dayRecord = DayRecord(date: prevKeyDate, ibsRecords: currentIBSRecords)
      recordsByDay.append(dayRecord)
    }

    return (recordsByDay, computedRecords)
  }
}
