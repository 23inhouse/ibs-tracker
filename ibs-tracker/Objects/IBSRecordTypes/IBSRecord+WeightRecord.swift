//
//  IBSRecord+WeightRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol WeightRecord : IBSRecordType {
  var weight: Double? { get }
  init(weight: Double, date: Date, tags: [String])
}

extension IBSRecord: WeightRecord {
  init(weight: Double, date: Date, tags: [String] = []) {
    self.type = .weight
    self.timestamp = date.timestampString()
    self.weight = weight
    self.tags = tags
  }
}
