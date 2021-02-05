//
//  IBSRecord+NoteRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol NoteRecord : IBSRecordType {
  var text: String? { get }
  init(note text: String, date: Date, tags: [String])
}

extension IBSRecord: NoteRecord {
  init(note text: String, date: Date, tags: [String] = []) {
    self.type = .note
    self.timestamp = date.timestampString()
    self.text = text
    self.tags = tags
  }
}
