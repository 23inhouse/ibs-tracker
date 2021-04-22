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
  var mealType: MealType? { get }
  var mealTooLate: Scales? { get }
  var mealTooLong: Scales? { get }
  var mealTooSoon: Scales? { get }
  var durationInMinutes: TimeInterval { get }
  init(timestamp: Date, food: String, tags: [String], risk: Scales?, size: FoodSizes?, speed: Scales?, medicinal: Bool, mealType: MealType?)
  func FoodScore() -> Int
  func foodDescription() -> String
  func riskText() -> String
  func sizeText() -> String
  func speedText() -> String
  func mealTypeText() -> String
  func mealTooLateText() -> String
  func mealTooLongText() -> String
  func mealTooSoonText() -> String
}

extension IBSRecord: FoodRecord {
  init(timestamp: Date, food: String, tags: [String] = [], risk: Scales?, size: FoodSizes?, speed: Scales?, medicinal: Bool = false, mealType: MealType? = nil) {
    self.type = .food
    self.timestamp = timestamp
    self.text = food
    self.risk = risk
    self.size = size
    self.speed = speed
    self.medicinal = medicinal
    self.mealType = mealType
    self.tags = tags
  }

  var durationInMinutes: TimeInterval {
    get {
      let size = (size ?? .normal).rawValue
      let speed = (speed ?? .mild).rawValue

      let normalDurationInMinutes = 20
      let sizeInMinutes = (size - 1) * 5 // -5 ... 15 minutes (15 ... 35 minutes)
      let speedCubed = (speed - 1) * (speed - 1) * (speed - 1)
      let speedFactor = Double(speedCubed) / 3 + 1 // 0.66, 1, 1.33, 3.66, 10

      return round(Double(normalDurationInMinutes + sizeInMinutes) / speedFactor * 10) / 10
    }
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

  func mealTypeText() -> String {
    guard let mealType = mealType else { return "Snack" }
    return mealType.rawValue.capitalized
  }

  func mealTooLateText() -> String {
    return Scales.mealTooLateDescriptions[mealTooLate ?? .none] ?? ""
  }

  func mealTooLongText() -> String {
    return Scales.mealTooLongDescriptions[mealTooLong ?? .none] ?? ""
  }

  func mealTooSoonText() -> String {
    return Scales.mealTooSoonDescriptions[mealTooSoon ?? .none] ?? ""
  }
}
