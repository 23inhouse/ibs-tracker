//
//  IBSRecord+BMRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol BMRecord: IBSRecordType {
  var bristolScale: BristolType? { get }
  var color: BMColor? { get }
  var pressure: Scales? { get }
  var smell: BMSmell? { get }
  var evacuation: BMEvacuation? { get }
  var dryness: Scales? { get }
  var wetness: Scales? { get }
  var numberOfBMs: UInt? { get }
  var numberOfBMsScale: Scales? { get }

  init(timestamp: Date, bristolScale: BristolType?, tags: [String], color: BMColor?, pressure: Scales?, smell: BMSmell?, evacuation: BMEvacuation?, dryness: Scales?, wetness: Scales?)
  func bmScore() -> Scales
  func bristolDescription() -> String
  func colorText() -> String
  func pressureText() -> String
  func smellText() -> String
  func evacuationText() -> String
  func wetnessText() -> String
  func drynessText() -> String
  func numberOfBMsText() -> String
}

extension IBSRecord: BMRecord {
  init(timestamp: Date, bristolScale: BristolType? = nil, tags: [String] = [], color: BMColor? = nil, pressure: Scales? = nil, smell: BMSmell? = nil, evacuation: BMEvacuation? = nil, dryness: Scales? = nil, wetness: Scales? = nil) {
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

  var numberOfBMsScale: Scales? {
    get {
      let number = numberOfBMs ?? 0
      let scale: Scales
      if number == 0 {
        scale = .none
      } else if number == 1 {
        scale = .zero
      } else if number == 2 {
        scale = .mild
      } else if number == 3 {
        scale = .moderate
      } else if number == 4 {
        scale = .severe
      } else {
        scale = .extreme
      }
      return scale
    }
  }

  func bmScore() -> Scales {
    let scales = [dryness ?? .none, wetness ?? .none, pressure ?? .none, numberOfBMsScale ?? .none]
    let worst: Scales = scales.max { a, b in a.rawValue < b.rawValue } ?? .none

    guard let bristolScale = bristolScale else { return .none }

    switch bristolScale {
    case .b0, .b7:
      return .extreme

    case .b1, .b6:
      if evacuation == .partial {
        return .extreme
      }
      if worst.rawValue > Scales.severe.rawValue {
        return worst
      }

      return .severe

    case .b2, .b5:
      if worst.rawValue > Scales.severe.rawValue {
        return worst
      }
      if evacuation == .partial {
        return .severe
      }
      if worst.rawValue > Scales.moderate.rawValue {
        return worst
      }

      return .moderate

    case .b3, .b4:
      if worst.rawValue > Scales.moderate.rawValue {
        return worst
      }
      if evacuation == .partial {
        return .moderate
      }
      if worst.rawValue > Scales.zero.rawValue {
        return worst
      }

      return .zero
    }
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
    return Scales.drynessDescriptions[dryness ?? .zero] ?? ""
  }

  func wetnessText() -> String {
    return Scales.wetnessDescriptions[wetness ?? .zero] ?? ""
  }

  func numberOfBMsText() -> String {
    let scale = numberOfBMsScale ?? .none
    return Scales.numberOfBMsDescriptions[scale] ?? ""
  }
}
