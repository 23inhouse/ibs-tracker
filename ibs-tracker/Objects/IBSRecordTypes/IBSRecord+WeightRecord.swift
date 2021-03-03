//
//  IBSRecord+WeightRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol WeightRecord: IBSRecordType {
  var weight: Decimal? { get }
  init(weight: Decimal, timestamp: Date, tags: [String])
}

extension IBSRecord: WeightRecord {
  init(weight: Decimal, timestamp: Date, tags: [String] = []) {
    self.type = .weight
    self.timestamp = timestamp
    self.weight = weight
    self.tags = tags
  }
}
