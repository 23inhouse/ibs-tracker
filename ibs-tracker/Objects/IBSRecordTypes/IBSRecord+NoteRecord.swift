//
//  IBSRecord+NoteRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol NoteRecord: IBSRecordType {
  var text: String? { get }
  init(timestamp: Date, note text: String, tags: [String])
}

extension IBSRecord: NoteRecord {
  init(timestamp: Date, note text: String, tags: [String] = []) {
    self.type = .note
    self.timestamp = timestamp
    self.text = text
    self.tags = tags
  }
}
