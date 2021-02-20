//
//  IBSRecord+BMRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol BMRecord : IBSRecordType {
  var bristolScale: BristolType? { get }
  init(bristolScale scale: Int, timestamp: Date, tags: [String])
  func bristolDescription() -> String
}

extension IBSRecord: BMRecord {
  init(bristolScale scale: Int, timestamp: Date, tags: [String] = []) {
    self.type = .bm
    self.timestamp = timestamp
    self.bristolScale = BristolType(rawValue: scale)
    self.tags = tags
  }

  func bristolDescription() -> String {
    guard let bristolScale = bristolScale else { return "" }

    let bristolScaleDescriptions: [BristolType: String] = [
      .b0: "No Movement Constipation",
      .b1: "Separate hard lumps",
      .b2: "Lumpy & sausage-like",
      .b3: "Sausage shape with cracks",
      .b4: "Perfectly smooth sausage",
      .b5: "Soft blobs with clear-cut edges",
      .b6: "Mushy with ragged edges",
      .b7: "Liquid with no solid pieces"
    ]
    return bristolScaleDescriptions[bristolScale] ?? ""
  }
}
