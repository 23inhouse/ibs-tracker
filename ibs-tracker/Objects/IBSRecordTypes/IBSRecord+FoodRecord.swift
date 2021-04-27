//
//  IBSRecord+FoodRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol FoodRecord: IBSRecordType {
  var text: String? { get }
  var speed: Scales? { get }
  var size: FoodSizes? { get }
  var risk: Scales? { get }
  var medicinal: Bool? { get }
  init(timestamp: Date, food: String, tags: [String], risk: Scales?, size: FoodSizes?, speed: Scales?, medicinal: Bool)
  func FoodScore() -> Int
  func foodDescription() -> String
  func riskText() -> String
  func sizeText() -> String
  func speedText() -> String
}

extension IBSRecord: FoodRecord {
  init(timestamp: Date, food: String, tags: [String] = [], risk: Scales?, size: FoodSizes?, speed: Scales?, medicinal: Bool = false) {
    self.type = .food
    self.timestamp = timestamp
    self.text = food
    self.risk = risk
    self.size = size
    self.speed = speed
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

  func speedText() -> String {
    return Scales.foodSpeedDescriptions[speed ?? .none] ?? ""
  }
}
