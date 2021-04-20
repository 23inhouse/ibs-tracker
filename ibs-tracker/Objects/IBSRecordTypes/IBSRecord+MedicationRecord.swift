//
//  IBSRecord+MedicationRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol MedicationRecord: IBSRecordType {
  var text: String? { get }
  var medicationType: [MedicationType]? { get }
  init(medication text: String, type medicationType: [MedicationType], timestamp: Date, tags: [String])
}

extension IBSRecord: MedicationRecord {
  init(medication text: String, type medicationType: [MedicationType], timestamp: Date, tags: [String] = []) {
    self.type = .medication
    self.timestamp = timestamp
    self.text = text
    self.medicationType = medicationType
    self.tags = tags
  }
}
