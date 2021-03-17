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
    case color
    case pressure
    case smell
    case evacuation
    case dryness
    case wetness
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
    case condition
    case tags
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    type = ItemType(from: try values.decode(String.self, forKey: .type))
    timestamp = try IBSRecord.timestamp(from: try values.decode(String.self, forKey: .timestamp))
    bristolScale = BristolType(optionalValue: try values.decodeIfPresent(Int.self, forKey: .bristolScale))
    color = BMColor(optionalValue: try values.decodeIfPresent(String.self, forKey: .color))
    pressure = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .pressure))
    smell = BMSmell(optionalValue: try values.decodeIfPresent(String.self, forKey: .smell))
    evacuation = BMEvacuation(optionalValue: try values.decodeIfPresent(String.self, forKey: .evacuation))
    dryness = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .dryness))
    wetness = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .wetness))
    text = try values.decodeIfPresent(String.self, forKey: .text)
    size = FoodSizes(optionalValue: try values.decodeIfPresent(Int.self, forKey: .size))
    risk = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .risk))
    pain = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .pain))
    bloating = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .bloating))
    bodyache = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .bodyache))
    headache = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .headache))
    feel = MoodType(optionalValue: try values.decodeIfPresent(Int.self, forKey: .feel))
    stress = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .stress))
    let medicationTypes = try values.decodeIfPresent([String].self, forKey: .medicationType)
    medicationType = medicationTypes?.map { MedicationType(from: $0) ?? .other }
    weight = try values.decodeIfPresent(Decimal.self, forKey: .weight)
    condition = Scales(optionalValue: try values.decodeIfPresent(Int.self, forKey: .condition))
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
    try container.encodeIfPresent(color?.optionalValue, forKey: .color)
    try container.encodeIfPresent(pressure?.optionalValue, forKey: .pressure)
    try container.encodeIfPresent(smell?.optionalValue, forKey: .smell)
    try container.encodeIfPresent(evacuation?.optionalValue, forKey: .evacuation)
    try container.encodeIfPresent(dryness?.optionalValue, forKey: .dryness)
    try container.encodeIfPresent(wetness?.optionalValue, forKey: .wetness)
    try container.encodeIfPresent(text, forKey: .text)
    try container.encodeIfPresent(size?.optionalValue, forKey: .size)
    try container.encodeIfPresent(risk?.optionalValue, forKey: .risk)
    try container.encodeIfPresent(pain?.optionalValue, forKey: .pain)
    try container.encodeIfPresent(bloating?.optionalValue, forKey: .bloating)
    try container.encodeIfPresent(bodyache?.optionalValue, forKey: .bodyache)
    try container.encodeIfPresent(headache?.optionalValue, forKey: .headache)
    try container.encodeIfPresent(feel?.optionalValue, forKey: .feel)
    try container.encodeIfPresent(stress?.optionalValue, forKey: .stress)
    if let medicationTypeData = medicationType {
      try container.encode(medicationTypeData, forKey: .medicationType)
    }
    try container.encodeIfPresent(weight, forKey: .weight)
    try container.encodeIfPresent(condition?.optionalValue, forKey: .condition)
    try container.encodeIfPresent(tags, forKey: .tags)
  }
}
