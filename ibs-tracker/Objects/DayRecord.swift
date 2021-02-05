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
  static func keyString(for timestamp: String) -> String? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    guard let date = formatter.date(from: timestamp) else {
      print("Error: No Date")
      return nil
    }
    guard let keyDate = keyDate(for: date) else {
      print("Error: No key")
      return nil
    }

    return keyDate.string(for: "yyyy-MM-dd")
  }

  // keyDate moves records before 5am to the previous day
  // So a record at 2am will be display after the 11pm records
  // In the context of food and ibs 5am is the start of a new day
  static func keyDate(for date: Date) -> Date? {
    return Calendar.current.date(byAdding: .hour, value: -5, to: date)
  }

}
