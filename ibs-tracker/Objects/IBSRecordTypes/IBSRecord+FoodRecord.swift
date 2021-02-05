//
//  IBSRecord+FoodRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol FoodRecord : IBSRecordType {
  var text: String? { get }
  var size: Int? { get }
  var risk: Int? { get }
  init(food: String, timestamp: Date, tags: [String], risk: Int?, size: Int?)
  func FoodScore() -> Int
  func riskText() -> String
  func sizeText() -> String
}

extension IBSRecord: FoodRecord {
  init(food: String, timestamp: Date, tags: [String] = [], risk: Int?, size: Int?) {
    self.type = .food
    self.timestamp = timestamp.timestampString()
    self.text = food
    self.risk = risk
    self.size = size
    self.tags = tags
  }

  func FoodScore() -> Int {
    [risk ?? 0, size ?? 0].max() ?? 0
  }

  func riskText() -> String {
    let texts: [Scales: String] = [
      .zero: "no risk at all",
      .mild: "mildly risky",
      .moderate: "moderatly risky",
      .severe: "I should't eat this",
      .extreme: "I know I can't eat this",
    ]

    let scaleText = Scales(rawValue: risk ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func sizeText() -> String {
    let texts: [Scales: String] = [
      .zero: "Very small meal",
      .mild: "Small meal",
      .moderate: "Normal meal size",
      .severe: "A bit too much",
      .extreme: "Way to much",
    ]

    let scaleText = Scales(rawValue: size ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}
