//
//  DayRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

struct DayRecord: Identifiable {
  var id = UUID()
  private(set) var date: Date
  private(set) var ibsRecords: [IBSRecord]
}

extension DayRecord {
  // keyDate moves records before 5am to the previous day
  // So a record at 2am will be display after the 11pm records
  // In the context of food and ibs 5am is the start of a new day
  static func keyDate(for date: Date) -> Date? {
    return IBSData.currentDate(for: date)
  }
}
