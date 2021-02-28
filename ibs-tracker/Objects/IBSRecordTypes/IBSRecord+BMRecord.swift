//
//  IBSRecord+BMRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol BMRecord : IBSRecordType {
  var bristolScale: BristolType? { get }
  init(bristolScale: BristolType?, timestamp: Date, tags: [String])
  func bristolDescription() -> String
}

extension IBSRecord: BMRecord {
  init(bristolScale: BristolType? = nil, timestamp: Date, tags: [String] = []) {
    self.type = .bm
    self.timestamp = timestamp
    self.bristolScale = bristolScale
    self.tags = tags
  }

  func bristolDescription() -> String {
    guard let bristolScale = bristolScale else { return "" }
    return BristolType.descriptions[bristolScale] ?? ""
  }
}
