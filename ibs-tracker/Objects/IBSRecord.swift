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
}
