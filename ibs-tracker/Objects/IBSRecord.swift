//
//  IBSRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 5/2/21.
//

import Foundation

struct IBSRecord {
  var type: ItemType
  var timestamp: String
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

  var date: Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    return formatter.date(from: timestamp)!
  }
}

extension IBSRecord: Hashable {}
