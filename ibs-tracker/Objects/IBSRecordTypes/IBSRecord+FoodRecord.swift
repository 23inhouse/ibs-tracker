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
  var medicinal: Bool? { get }
  init(food: String, timestamp: Date, tags: [String], risk: Scales?, size: FoodSizes?, medicinal: Bool)
  func FoodScore() -> Int
  func foodDescription() -> String
  func riskText() -> String
  func sizeText() -> String
}

extension IBSRecord: FoodRecord {
  init(food: String, timestamp: Date, tags: [String] = [], risk: Scales?, size: FoodSizes?, medicinal: Bool = false) {
    self.type = .food
    self.timestamp = timestamp
    self.text = food
    self.risk = risk
    self.size = size
    self.medicinal = medicinal
    self.tags = tags
  }

  func FoodScore() -> Int {
    [risk?.rawValue ?? 0, size?.rawValue ?? 0].max() ?? 0
  }

  func foodDescription() -> String {
    var modifiers = [riskText(), sizeText()].filter { $0 != "" }.joined(separator: " & ")
    modifiers = modifiers != "" ? "(\(modifiers))" : ""
    let name = text ?? ""
    return modifiers != "" ? "\(modifiers) \(name)" : name
  }

  func riskText() -> String {
    return Scales.foodRiskDescriptions[risk ?? .none] ?? ""
  }

  func sizeText() -> String {
    return FoodSizes.descriptions[size ?? .none] ?? ""
  }
}
