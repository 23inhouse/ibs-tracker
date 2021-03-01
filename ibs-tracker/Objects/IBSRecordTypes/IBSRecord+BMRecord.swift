//
//  IBSRecord+BMRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol BMRecord : IBSRecordType {
  var bristolScale: BristolType? { get }
  var color: BMColor? { get }
  var pressure: Scales? { get }
  var smell: BMSmell? { get }
  var evacuation: BMEvacuation? { get }
  var dryness: Scales? { get }
  var wetness: Scales? { get }
  init(bristolScale: BristolType?, timestamp: Date, tags: [String], color: BMColor?, pressure: Scales?, smell: BMSmell?, evacuation: BMEvacuation?, dryness: Scales?, wetness: Scales?)
  func bristolDescription() -> String
  func colorText() -> String
  func pressureText() -> String
  func smellText() -> String
  func evacuationText() -> String
  func wetnessText() -> String
  func drynessText() -> String
}

extension IBSRecord: BMRecord {
  init(bristolScale: BristolType? = nil, timestamp: Date, tags: [String] = [], color: BMColor? = nil, pressure: Scales? = nil, smell: BMSmell? = nil, evacuation: BMEvacuation? = nil, dryness: Scales? = nil, wetness: Scales? = nil) {
    self.type = .bm
    self.timestamp = timestamp
    self.bristolScale = bristolScale
    self.color = color
    self.pressure = pressure
    self.smell = smell
    self.evacuation = evacuation
    self.dryness = dryness
    self.wetness = wetness
    self.tags = tags
  }

  func bristolDescription() -> String {
    guard let bristolScale = bristolScale else { return "" }
    return BristolType.descriptions[bristolScale] ?? ""
  }

  func colorText() -> String {
    return color?.rawValue ?? ""
  }

  func pressureText() -> String {
    return Scales.pressureDescriptions[pressure ?? .zero] ?? ""
  }

  func smellText() -> String {
    guard let smell = smell else { return "" }
    return BMSmell.descriptions[smell] ?? ""
  }

  func evacuationText() -> String {
    guard let evacuation = evacuation else { return "" }
    return BMEvacuation.descriptions[evacuation] ?? ""
  }

  func drynessText() -> String {
    return Scales.pressureDescriptions[dryness ?? .zero] ?? ""
  }

  func wetnessText() -> String {
    return Scales.pressureDescriptions[wetness ?? .zero] ?? ""
  }
}
