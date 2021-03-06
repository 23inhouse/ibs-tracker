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
  init(timestamp: Date, medication text: String, type medicationType: [MedicationType], tags: [String])
  func calcMedicationMetaTags() -> [String]
}

extension IBSRecord: MedicationRecord {
  init(timestamp: Date, medication text: String, type medicationType: [MedicationType], tags: [String] = []) {
    self.type = .medication
    self.timestamp = timestamp
    self.text = text
    self.medicationType = medicationType
    self.tags = tags
  }

  func calcMedicationMetaTags() -> [String] {
    let medicationTypes: [String] = medicationType.map({ ["\($0)"] }) ?? []
    return ["\(type)", text ?? ""] + medicationTypes + tags
  }
}
