//
//  AppDB+Records.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 2/2/21.
//

import Foundation
import GRDB

extension AppDB {
  func exportRecords() throws -> [IBSRecord] {
    let tags = try tagRecords().reduce(into: [Int64: String]()) { $0[$1.ID!] = $1.name }

    let ibsTags = try ibsTagRecords().reduce(into: [Int64: [Int64]]()) {
      $0[$1.ibsID, default: []].append($1.tagID)
    }

    return try ibsRecords().map { record in
      let recordID = record.ID ?? 0
      let tagIDs = ibsTags[recordID] ?? []
      let tagNames:[String] = tagIDs.compactMap { tagID in tags[tagID] }
      return IBSRecord(from: record, tags: tagNames)
    }
  }

  func importJSON(_ data: Data, truncate: Bool = false) {
    let jsonDecoder = JSONDecoder()
    do {
      let dataSet = try jsonDecoder.decode(DataSet.self, from: data)
      if truncate {
        try truncateRecords()
      }
      try importRecords(dataSet.ibsRecords)
    } catch {
      print("Error: \(error)")
    }
  }

  func importRecords(_ allRecords: [IBSRecord]) throws {
    let sortedRecords = allRecords.sorted { $0.timestamp < $1.timestamp }

    for record in sortedRecords {
      try record.insertSQL(into: self)
    }
  }

  func truncateRecords() throws {
    try deleteAllRecords(in: SQLIBSTagRecord.self)
    try deleteAllRecords(in: SQLIBSRecord.self)
    try deleteAllRecords(in: SQLTagRecord.self)
  }

  func ibsTagIDs(ibsID: Int64) throws -> [Int64?] {
    return try dbWriter.read { db in
      let request = SQLIBSTagRecord
        .select([Column("ID"), Column("ibsID"), Column("tagID")])
        .filter(Column("ibsID") == ibsID)

      return try request.fetchAll(db).map { $0.ID }
    }
  }
}

private extension AppDB {
  func ibsRecords() throws -> [SQLIBSRecord] {
    return try dbWriter.read { db in
      let request = SQLIBSRecord
        .order([Column("timestamp").desc, Column("type").desc])

      return try request.fetchAll(db)
    }
  }

  func ibsTagRecords() throws -> [SQLIBSTagRecord] {
    return try dbWriter.read { db in
      let request = SQLIBSTagRecord
        .select([Column("ibsID"), Column("tagID")])

      return try request.fetchAll(db)
    }
  }

  func tagRecords() throws -> [SQLTagRecord] {
    return try dbWriter.read { db in
      let request = SQLTagRecord
        .select([Column("ID"), Column("type"), Column("name")])

      return try request.fetchAll(db)
    }
  }
}
