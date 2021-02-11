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
    self.bristolScale = record.bristolScale
    self.size = record.size
    self.risk = record.risk
    self.bloating = record.bloating
    self.pain = record.pain
    self.bodyache = record.bodyache
    self.headache = record.headache
    self.feel = record.feel
    self.stress = record.stress
    self.medicationType = MedicationType(rawValue: record.medicationType ?? "") ?? .none
    self.weight = record.weight

    if let tags = tags {
      self.tags = tags
    }
  }
}
