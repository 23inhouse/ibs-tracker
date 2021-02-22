//
//  IBSRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 5/2/21.
//

import Foundation

struct IBSRecord {
  var type: ItemType
  var timestamp: Date
  var bristolScale: BristolType?
  var text: String?
  var size: FoodSizes?
  var risk: Scales?
  var pain: Scales?
  var bloating: Scales?
  var bodyache: Scales?
  var headache: Scales?
  var feel: MoodType?
  var stress: Scales?
  var medicationType: MedicationType?
  var weight: Decimal?
  var tags: [String] = []

  static let foodRiskTexts: [Scales: String] = [
    .zero: "no risk at all",
    .mild: "mildly risky",
    .moderate: "moderatly risky",
    .severe: "I should't eat this",
    .extreme: "I know I can't eat this",
  ]

  static let foodSizeTexts: [FoodSizes: String] = [
    .tiny: "tiny portion",
    .small: "small portion",
    .normal: "normal portion",
    .large: "large portion",
    .huge: "huge portion",
  ]
}

extension IBSRecord: Hashable {}

extension IBSRecord {
  init(comparable other: IBSRecord) {
    self.type = other.type
    self.timestamp = Date.init(timeIntervalSinceReferenceDate: 0)
    self.bristolScale = other.bristolScale ?? BristolType.none
    self.text = other.text?.lowercased()
    self.size = nil
    self.risk = nil
    self.pain = other.pain ?? Scales.none
    self.bloating = other.bloating ?? Scales.none
    self.bodyache = other.bodyache ?? Scales.none
    self.headache = other.headache ?? Scales.none
    self.feel = other.feel ?? MoodType.none
    self.stress = other.stress ?? Scales.none
    self.medicationType = other.medicationType ?? MedicationType.none
    self.weight = other.weight
    self.tags = other.tags.sorted().map { $0.lowercased() }
  }

  func weightedValue(count: Int, maxCount: Int, yesterday: Date, daysOfInterest: Int = 42) -> Int {
    let secondsPerDay: Double = 86400
    let yesterdayInterval = yesterday.timeIntervalSinceReferenceDate
    let timestampInterval = timestamp.timeIntervalSinceReferenceDate

    let interval: TimeInterval = yesterdayInterval - timestampInterval
    let daysSince = Int(interval / secondsPerDay)

    let factor = Double(daysOfInterest * daysOfInterest)

    var value: Int = 0
    value += Int(factor - Double(daysSince * daysSince)) // curved so value decreases rapidly as the age aproaches daysOfInterest
    value += Int(Double(count).squareRoot() / Double(maxCount).squareRoot() * factor / 2) // curved so values decrease slowly as the count decreases
    return value
  }
}
