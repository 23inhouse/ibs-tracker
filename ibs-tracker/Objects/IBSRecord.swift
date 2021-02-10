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
  var bristolScale: Int?
  var text: String?
  var size: Int?
  var risk: Int?
  var pain: Int?
  var bloating: Int?
  var bodyache: Int?
  var headache: Int?
  var feel: Int?
  var stress: Int?
  var medicationType: MedicationType?
  var weight: Double?
  var tags: [String] = []
}

extension IBSRecord: Hashable {}
