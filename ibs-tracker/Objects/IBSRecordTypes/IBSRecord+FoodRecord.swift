//
//  IBSRecord+FoodRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol FoodRecord: IBSRecordType {
  var text: String? { get }
  var size: FoodSizes? { get }
  var risk: Scales? { get }
  init(food: String, timestamp: Date, tags: [String], risk: Scales?, size: FoodSizes?)
  func FoodScore() -> Int
}

extension IBSRecord: FoodRecord {
  init(food: String, timestamp: Date, tags: [String] = [], risk: Scales?, size: FoodSizes?) {
    self.type = .food
    self.timestamp = timestamp
    self.text = food
    self.risk = risk
    self.size = size
    self.tags = tags
  }

  func FoodScore() -> Int {
    [risk?.rawValue ?? 0, size?.rawValue ?? 0].max() ?? 0
  }
}
