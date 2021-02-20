//
//  IBSRecord+GRDB.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 11/2/21.
//

import Foundation
import GRDB

extension IBSRecord {
  init(from record: SQLIBSRecord, tags: [String]? = nil) {
    self.timestamp = record.timestamp
    self.type = ItemType(rawValue: record.type) ?? .none

    self.text = record.text
    self.bristolScale = BristolType(rawValue: record.bristolScale ?? -1)
    self.size = FoodSizes(rawValue: record.size ?? -1)
    self.risk = Scales(rawValue: record.risk ?? -1)
    self.bloating = Scales(rawValue: record.bloating ?? -1)
    self.pain = Scales(rawValue: record.pain ?? -1)
    self.bodyache = Scales(rawValue: record.bodyache ?? -1)
    self.headache = Scales(rawValue: record.headache ?? -1)
    self.feel = MoodType(rawValue: record.feel ?? -1)
    self.stress = Scales(rawValue: record.stress ?? -1)
    self.medicationType = MedicationType(rawValue: record.medicationType ?? "") ?? MedicationType.none
    self.weight = record.weight

    self.tags = tags ?? []
  }
}
