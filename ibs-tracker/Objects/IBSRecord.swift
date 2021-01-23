//
//  IBSRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import Foundation


private func timestampString(for date: Date? = Date()) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
  return dateFormatter.string(from: date ?? Date())
}

struct IBSRecord: Decodable, Hashable {
  var type: ItemType
  var timestamp: String
  var bristolScale: Int?
  var text: String?
  var size: String?
  var risk: String?
  var pain: Int?
  var bloating: Int?
  var headache: Int?
  var feel: Int?
  var stress: Int?
  var medicationType: MedicationType?
  var weight: Double?
  var tags: [String] = []

  enum CodingKeys: String, CodingKey {
    case type
    case timestamp
    case bristolScale = "bristol-scale"
    case text
    case size
    case risk
    case pain
    case bloating
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
    timestamp = try values.decode(String.self, forKey: .timestamp)
    bristolScale = try values.decodeIfPresent(Int.self, forKey: .bristolScale) ?? 0
    text = try values.decodeIfPresent(String.self, forKey: .text) ?? ""
    size = try values.decodeIfPresent(String.self, forKey: .size)
    risk = try values.decodeIfPresent(String.self, forKey: .risk)
    pain = try values.decodeIfPresent(Int.self, forKey: .pain)
    bloating = try values.decodeIfPresent(Int.self, forKey: .bloating)
    headache = try values.decodeIfPresent(Int.self, forKey: .headache)
    feel = try values.decodeIfPresent(Int.self, forKey: .feel)
    stress = try values.decodeIfPresent(Int.self, forKey: .stress)
    let medicationTypeString = try values.decodeIfPresent(String.self, forKey: .medicationType)
    medicationType = MedicationType(from: medicationTypeString)
    weight = try values.decodeIfPresent(Double.self, forKey: .weight)
    tags = try values.decodeIfPresent([String].self, forKey: .tags) ?? []
  }

  init(date: Date, tags: [String] = [], headache: Int?, pain: Int?) {
    type = .ache
    self.timestamp = timestampString(for: date)
    self.headache = headache
    self.pain = pain
    self.tags = tags
  }

  init(bristolScale scale: Int, date: Date, tags: [String] = []) {
    type = .bm
    self.timestamp = timestampString(for: date)
    bristolScale = scale
    self.tags = tags
  }

  init(food: String, timestamp: Date, tags: [String] = [], risk: String?, size: String?) {
    type = .food
    self.timestamp = timestampString(for: timestamp)
    text = food
    self.risk = risk
    self.size = size
    self.tags = tags
  }

  init(date: Date, tags: [String] = [], bloating: Int?, pain: Int?) {
    type = .gut
    self.timestamp = timestampString(for: date)
    self.bloating = bloating
    self.pain = pain
    self.tags = tags
  }

  init(note text: String, date: Date, tags: [String] = []) {
    type = .note
    self.timestamp = timestampString(for: date)
    self.text = text
    self.tags = tags
  }

  init(medication text: String, type medicationType: MedicationType, date: Date, tags: [String] = []) {
    type = .medication
    self.timestamp = timestampString(for: date)
    self.text = text
    self.medicationType = medicationType
    self.tags = tags
  }

  init(date: Date, tags: [String] = [], feel: Int?, stress: Int?) {
    type = .mood
    self.timestamp = timestampString(for: date)
    self.feel = feel
    self.stress = stress
    self.tags = tags
  }

  init(weight: Double, date: Date, tags: [String] = []) {
    type = .note
    self.timestamp = timestampString(for: date)
    self.weight = weight
    self.tags = tags
  }

  func dateString(for format: String = "h:mm a") -> String {
    dateString(for: format, dated: nil)
//    dateString(for: "dd MMM h:mm a")
  }

  func date() -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    return formatter.date(from: timestamp)!
  }

  func keyString() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    guard let date = formatter.date(from: timestamp) else {
      print("Error: No Date")
      return ""
    }
    guard let keyDate = Calendar.current.date(byAdding: .hour, value: -5, to: date) else {
      print("Error: No key")
      return ""
    }

    return dateString(for: "yyyy-MM-dd", dated: keyDate)
  }

  func keyDate() -> Date? {
    return Calendar.current.date(byAdding: .hour, value: -5, to: date())
  }

  private func dateString(for format: String, dated date: Date? = nil) -> String {
    let currentTimestamp = date != nil ? timestampString(for: date) : timestamp

    var abbreviation: String = "UTC"
    if format != "Z" {
      abbreviation = dateString(for: "Z")
    }

    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: abbreviation)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    let datetime = formatter.date(from: currentTimestamp)!
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = format
    return formatter.string(from: datetime)
  }
}
