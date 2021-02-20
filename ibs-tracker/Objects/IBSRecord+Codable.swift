//
//  IBSRecord+Codable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

extension IBSRecord: Codable {
  enum CodingKeys: String, CodingKey {
    case type
    case timestamp
    case bristolScale = "bristol-scale"
    case text
    case size
    case risk
    case pain
    case bloating
    case bodyache
    case headache
    case feel
    case stress
    case medicationType = "medication-type"
    case weight
    case tags
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    let typeString = try values.decode(String.self, forKey: .type)
    type = ItemType(from: typeString)
    let timestampString = try values.decode(String.self, forKey: .timestamp)
    timestamp = try IBSRecord.timestamp(from: timestampString)
    if let bristolScaleInt = try values.decodeIfPresent(Int.self, forKey: .bristolScale) {
      bristolScale = BristolType(rawValue: bristolScaleInt)
    }
    text = try values.decodeIfPresent(String.self, forKey: .text)
    if let sizeInt = try values.decodeIfPresent(Int.self, forKey: .size) {
      size = FoodSizes(rawValue: sizeInt)
    }
    if let riskInt = try values.decodeIfPresent(Int.self, forKey: .risk) {
      risk = Scales(rawValue: riskInt)
    }
    if let painInt = try values.decodeIfPresent(Int.self, forKey: .pain) {
      pain = Scales(rawValue: painInt)
    }
    if let bloatingInt = try values.decodeIfPresent(Int.self, forKey: .bloating) {
      bloating = Scales(rawValue: bloatingInt)
    }
    if let bodyacheInt = try values.decodeIfPresent(Int.self, forKey: .bodyache) {
      bodyache = Scales(rawValue: bodyacheInt)
    }
    if let headacheInt = try values.decodeIfPresent(Int.self, forKey: .headache) {
      headache = Scales(rawValue: headacheInt)
    }
    if let feelInt = try values.decodeIfPresent(Int.self, forKey: .feel) {
      feel = MoodType(rawValue: feelInt)
    }
    if let stressInt = try values.decodeIfPresent(Int.self, forKey: .stress) {
      stress = Scales(rawValue: stressInt)
    }
    if let medicationTypeString = try values.decodeIfPresent(String.self, forKey: .medicationType) {
      medicationType = MedicationType(from: medicationTypeString)
    }
    weight = try values.decodeIfPresent(Decimal.self, forKey: .weight)
    tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []
  }

  static func timestamp(from timestamp: String) throws -> Date {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = Date.format
    guard let date = formatter.date(from: timestamp) else {
      throw "Couldn't create the date from [\(timestamp)]"
    }
    return date
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(type.rawValue, forKey: .type)
    try container.encode(timestamp.timestampString(), forKey: .timestamp)

    try container.encodeIfPresent(bristolScale, forKey: .bristolScale)
    try container.encodeIfPresent(text, forKey: .text)
    try container.encodeIfPresent(size?.rawValue, forKey: .size)
    try container.encodeIfPresent(risk?.rawValue, forKey: .risk)
    try container.encodeIfPresent(pain?.rawValue, forKey: .pain)
    try container.encodeIfPresent(bloating?.rawValue, forKey: .bloating)
    try container.encodeIfPresent(bodyache?.rawValue, forKey: .bodyache)
    try container.encodeIfPresent(headache?.rawValue, forKey: .headache)
    try container.encodeIfPresent(feel?.rawValue, forKey: .feel)
    try container.encodeIfPresent(stress?.rawValue, forKey: .stress)
    try container.encodeIfPresent(medicationType?.rawValue, forKey: .medicationType)
    try container.encodeIfPresent(weight, forKey: .weight)
    try container.encodeIfPresent(tags, forKey: .tags)
  }
}
