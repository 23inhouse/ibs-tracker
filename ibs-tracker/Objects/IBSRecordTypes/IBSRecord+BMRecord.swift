//
//  IBSRecord+BMRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol BMRecord : IBSRecordType {
  var bristolType: BristolType? { get }
  init(bristolScale scale: Int, date: Date, tags: [String])
  func bristolDescription() -> String
}

extension IBSRecord: BMRecord {
  init(bristolScale scale: Int, date: Date, tags: [String] = []) {
    self.type = .bm
    self.timestamp = date.timestampString()
    self.bristolScale = scale
    self.tags = tags
  }

  func bristolDescription() -> String {
    guard let bristolScale = bristolScale else { return "" }

    let bristolScaleDescriptions = [
      "No Movement Constipation",
      "Separate hard lumps",
      "Lumpy & sausage-like",
      "Sausage shape with cracks",
      "Perfectly smooth sausage",
      "Soft blobs with clear-cut edges",
      "Mushy with ragged edges",
      "Liquid with no solid pieces"
    ]
    return bristolScaleDescriptions[bristolScale]
  }

  var bristolType: BristolType? {
    BristolType(rawValue: bristolScale ?? 0)
  }
}
