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
  var numberOfBMs: UInt?
  var color: BMColor?
  var pressure: Scales?
  var smell: BMSmell?
  var evacuation: BMEvacuation?
  var dryness: Scales?
  var wetness: Scales?
  var text: String?
  var size: FoodSizes?
  var mealType: MealType?
  var mealTooLate: Scales?
  var mealTooLong: Scales?
  var mealTooSoon: Scales?
  var mealStart: Bool?
  var mealEnd: Bool?
  var risk: Scales?
  var speed: Scales?
  var pain: Scales?
  var bloating: Scales?
  var bodyache: Scales?
  var headache: Scales?
  var feel: MoodType?
  var stress: Scales?
  var medicationType: [MedicationType]?
  var weight: Decimal?
  var condition: Scales?
  var medicinal: Bool?
  var tags: [String] = []
  var metaTags: [String] = []
}

extension IBSRecord: Hashable {}

extension IBSRecord {
  init(comparable other: IBSRecord) {
    self.type = other.type
    self.timestamp = Date.init(timeIntervalSinceReferenceDate: 0)
    self.bristolScale = other.bristolScale
    self.color = other.color
    self.pressure = other.pressure
    self.smell = other.smell
    self.evacuation = other.evacuation
    self.dryness = other.dryness
    self.wetness = other.wetness
    self.text = other.text?.lowercased()
    self.size = nil
    self.risk = nil
    self.speed = nil
    self.pain = other.pain
    self.bloating = other.bloating
    self.bodyache = other.bodyache
    self.headache = other.headache
    self.feel = other.feel
    self.stress = other.stress
    self.medicationType = other.medicationType
    self.weight = other.weight
    self.condition = other.condition
    self.medicinal = nil
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

extension IBSRecord {
  static let summaryTypes: [ItemType] = [.ache, .bm, .food, .gut, .medication, .mood, .skin]

  var isNotMedicinalFood: Bool {
    get {
      type == .food && medicinal == false
    }
  }

  var isSummary: Bool {
    get {
      IBSRecord.summaryTypes.contains(type)
    }
  }

  func graphScore(include included: [ItemType] = [.ache, .bm, .gut, .mood, .skin]) -> Int {
    guard included.contains(type) else { return Scales.none.rawValue }

    switch type {
    case .ache:
      return acheScore().rawValue
    case .bm:
      return bmScore().rawValue
    case .gut:
      return gutScore().rawValue
    case .mood:
      return moodScore().rawValue
    case .skin:
      return skinScore().rawValue
    default:
      return Scales.none.rawValue
    }
  }
}
