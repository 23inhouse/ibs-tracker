//
//  AppDB+Records.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 2/2/21.
//

import GRDB

extension AppDB {
  func importRecords(_ allRecords: [IBSRecord]) throws {
    let sortedRecords = allRecords.sorted { $0.timestamp < $1.timestamp }

    for record in sortedRecords {
      var sqlRecord = SQLIBSRecord(from: record)
      let recordID = try insertRecord(&sqlRecord)

      for tagName in record.tags {
        var tagID: Int64?

        do {
          var sqlTagRecord = SQLTagRecord(name: tagName)
          tagID = try insertRecord(&sqlTagRecord)
        } catch {
          tagID = try selectRecord(in: SQLTagRecord.self, named: tagName)?.ID
        }

        guard tagID != nil else {
          throw "No tagID found or inserted for tag named [\(tagName)]"
        }

        var sqlIBSTagRecord = SQLIBSTagRecord(ibsID: recordID, tagID: tagID!)
        _ = try insertRecord(&sqlIBSTagRecord)
      }
    }
  }

  func truncateRecords() throws {
    try deleteAllRecords(in: SQLIBSTagRecord.self)
    try deleteAllRecords(in: SQLIBSRecord.self)
    try deleteAllRecords(in: SQLTagRecord.self)
  }
}
