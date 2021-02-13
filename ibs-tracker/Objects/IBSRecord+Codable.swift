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
    bristolScale = try values.decodeIfPresent(Int.self, forKey: .bristolScale)
    text = try values.decodeIfPresent(String.self, forKey: .text)
    size = try values.decodeIfPresent(Int.self, forKey: .size)
    risk = try values.decodeIfPresent(Int.self, forKey: .risk)
    pain = try values.decodeIfPresent(Int.self, forKey: .pain)
    bloating = try values.decodeIfPresent(Int.self, forKey: .bloating)
    bodyache = try values.decodeIfPresent(Int.self, forKey: .bodyache)
    headache = try values.decodeIfPresent(Int.self, forKey: .headache)
    feel = try values.decodeIfPresent(Int.self, forKey: .feel)
    stress = try values.decodeIfPresent(Int.self, forKey: .stress)
    if let medicationTypeString = try values.decodeIfPresent(String.self, forKey: .medicationType) {
      medicationType = MedicationType(from: medicationTypeString)
    }
    weight = try values.decodeIfPresent(Double.self, forKey: .weight)
    tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []
  }

  static func timestamp(from timestamp: String) throws -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    guard let date = formatter.date(from: timestamp) else {
      throw "Couldn't create the date from [\(timestamp)]"
    }
    return date
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(type.rawValue, forKey: .type)
    try container.encode(timestamp.timestampString(), forKey: .timestamp)
    try container.encodeIfPresent(size, forKey: .size)

    try container.encodeIfPresent(bristolScale, forKey: .bristolScale)
    try container.encodeIfPresent(text, forKey: .text)
    try container.encodeIfPresent(size, forKey: .size)
    try container.encodeIfPresent(risk, forKey: .risk)
    try container.encodeIfPresent(pain, forKey: .pain)
    try container.encodeIfPresent(bloating, forKey: .bloating)
    try container.encodeIfPresent(bodyache, forKey: .bodyache)
    try container.encodeIfPresent(headache, forKey: .headache)
    try container.encodeIfPresent(feel, forKey: .feel)
    try container.encodeIfPresent(stress, forKey: .stress)
    try container.encodeIfPresent(medicationType?.rawValue, forKey: .medicationType)
    try container.encodeIfPresent(weight, forKey: .weight)
    try container.encodeIfPresent(tags, forKey: .tags)
  }
}
