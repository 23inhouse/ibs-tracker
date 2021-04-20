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
