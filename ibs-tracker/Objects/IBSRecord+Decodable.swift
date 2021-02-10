//
//  IBSRecord+Decodable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

extension IBSRecord: Decodable {
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
    bristolScale = try values.decodeIfPresent(Int.self, forKey: .bristolScale) ?? 0
    text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
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
}
