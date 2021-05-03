//
//  IBSRecord+WeightRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol WeightRecord: IBSRecordType {
  var weight: Decimal? { get }
  init(timestamp: Date, weight: Decimal, tags: [String])
  func weightDescription() -> String
  func calcWeightMetaTags() -> [String]
}

extension IBSRecord: WeightRecord {
  init(timestamp: Date, weight: Decimal, tags: [String] = []) {
    self.type = .weight
    self.timestamp = timestamp
    self.weight = weight
    self.tags = tags
  }

  func weightDescription() -> String {
    guard let weight = weight else { return "" }
    return "\(String(describing: weight))kg"
  }

  func calcWeightMetaTags() -> [String] {
    return ["\(type)", weightDescription()] + tags
  }
}
