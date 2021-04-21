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

    let sortedRecords = records.sorted { $0.timestamp > $1.timestamp }

    guard sortedRecords.count > 0 else { return ([], []) }

    let keyStringFormat = "yyyy-MM-dd"
    let count = sortedRecords.count
    var i = 0
    var currentDayIBSRecords: [IBSRecord] = []
    var previousKeyString: String?
    var previousKeyDate: Date?

    repeat {
      let record = sortedRecords[i]
      i += 1

      let keyString = timeShiftedDate(for: record.timestamp).string(for: keyStringFormat)
      let keyDate = timeShiftedDate(for: record.timestamp)

      if keyString != previousKeyString {
        if currentDayIBSRecords.isNotEmpty, let prevKeyDate: Date = previousKeyDate {
          let records = calcMetaRecords(records: currentDayIBSRecords, date: prevKeyDate)
          let dayRecord = DayRecord(date: prevKeyDate, ibsRecords: records)
          computedRecords += records
          recordsByDay.append(dayRecord)
        }

        currentDayIBSRecords = []
      }

      currentDayIBSRecords.append(record)

      previousKeyString = keyString
      previousKeyDate = keyDate
    } while i < count

    if currentDayIBSRecords.isNotEmpty, let prevKeyDate: Date = previousKeyDate {
      let records = calcMetaRecords(records: currentDayIBSRecords, date: prevKeyDate)
      let dayRecord = DayRecord(date: prevKeyDate, ibsRecords: records)
      computedRecords += records
      recordsByDay.append(dayRecord)
    }

    return (recordsByDay, computedRecords.reversed())
  }
}

private extension IBSData {
  static func calcMetaRecords(records: [IBSRecord], date: Date) -> [IBSRecord] {
    var mutatableRecords = records
    let metaBMRecords = calcBMMetaRecords(records: &mutatableRecords, date: date)

    return (metaBMRecords + mutatableRecords).sorted { $0.timestamp > $1.timestamp }
  }

  static func calcBMMetaRecords(records: inout [IBSRecord], date: Date) -> [IBSRecord] {
    let timestamp = constipationTimestamp(date: date)
    let bmRecords = records.filter { $0.type == .bm }
    let count = bmRecords.count

    guard count > 0 else {
      return [IBSRecord(bristolScale: .b0, timestamp: timestamp)]
    }

    var numberOfBMs = 0
    for (i, record) in records.enumerated() {
      if record.type == .bm {
        records[i].numberOfBMs = UInt(count - numberOfBMs)
        numberOfBMs += 1
      }
    }

    return []
  }

  static func constipationTimestamp(date: Date) -> Date {
    let date = date.date()
    let hourOfDay = IBSData.numberOfHoursInMorningIncludedInPreviousDay + 1
    let interval = Double(hourOfDay * 60 * 60)
    return date.addingTimeInterval(interval)
  }
}
