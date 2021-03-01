//
//  IBSRecord+GRDB.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 11/2/21.
//

import Foundation
import GRDB

extension IBSRecord {
  init(from record: SQLIBSRecord, tags: [String]? = nil) {
    self.timestamp = record.timestamp
    self.type = ItemType(rawValue: record.type) ?? .none

    self.text = record.text
    self.bristolScale = BristolType(rawValue: record.bristolScale ?? -1)
    self.color = BMColor(rawValue: record.color ?? "") ?? BMColor.none
    self.pressure = Scales(rawValue: record.pressure ?? -1)
    self.smell = BMSmell(rawValue: record.smell ?? "") ?? BMSmell.none
    self.evacuation = BMEvacuation(rawValue: record.evacuation ?? "") ?? BMEvacuation.none
    self.dryness = Scales(rawValue: record.dryness ?? -1)
    self.wetness = Scales(rawValue: record.wetness ?? -1)
    self.size = FoodSizes(rawValue: record.size ?? -1)
    self.risk = Scales(rawValue: record.risk ?? -1)
    self.bloating = Scales(rawValue: record.bloating ?? -1)
    self.pain = Scales(rawValue: record.pain ?? -1)
    self.bodyache = Scales(rawValue: record.bodyache ?? -1)
    self.headache = Scales(rawValue: record.headache ?? -1)
    self.feel = MoodType(rawValue: record.feel ?? -1)
    self.stress = Scales(rawValue: record.stress ?? -1)
    self.medicationType = MedicationType(rawValue: record.medicationType ?? "") ?? MedicationType.none
    self.weight = record.weight

    self.tags = tags ?? []
  }

  func deleteSQL(into appDB: AppDB) throws {
    let sqlIBSRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: type.rawValue, at: timestamp)
    guard let recordID = sqlIBSRecord?.ID else { throw "Can't find record" }

    _ = try appDB.deleteRecords(in: SQLIBSRecord.self, ids: [recordID])
  }

  func insertSQL(into appDB: AppDB) throws {
    var sqlIBSRecord = SQLIBSRecord(from: self)
    _ = try appDB.insertRecord(&sqlIBSRecord)
    try updateTags(into: appDB, for: sqlIBSRecord)
  }

  func updateSQL(into appDB: AppDB, timestamp originalTimestamp: Date) throws {
    let sqlSelectedRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: type.rawValue, at: originalTimestamp)
    guard var sqlIBSRecord = sqlSelectedRecord else {
      throw "Error: Couldn't select the record"
    }
    guard let recordID = sqlIBSRecord.ID else {
      throw "Error: Record has no ID"
    }

    sqlIBSRecord.update(from: self)

    try appDB.saveRecord(&sqlIBSRecord)

    let sqlIBSTagIDs = try appDB.ibsTagIDs(ibsID: recordID)
    try appDB.deleteRecords(in: SQLIBSTagRecord.self, ids: sqlIBSTagIDs.compactMap { $0 })
    try updateTags(into: appDB, for: sqlIBSRecord)
  }
}

private extension IBSRecord {
  func updateTags(into appDB: AppDB, for sqlIBSRecord: SQLIBSRecord) throws {
    guard let recordID = sqlIBSRecord.ID else { return }

    for tagName in tags {
      var tagID: Int64?

      let validTagName = tagName.replacingOccurrences(of: "|", with: "--")

      do {
        var sqlTagRecord = SQLTagRecord(type: sqlIBSRecord.type, name: validTagName)
        tagID = try appDB.insertRecord(&sqlTagRecord)
      } catch {
        tagID = try appDB.selectRecord(in: SQLTagRecord.self, of: sqlIBSRecord.type, named: validTagName)?.ID
      }

      guard tagID != nil else {
        throw "No tagID found or inserted for tag named [\(validTagName)]"
      }

      var sqlIBSTagRecord = SQLIBSTagRecord(ibsID: recordID, tagID: tagID!)
      _ = try appDB.insertRecord(&sqlIBSTagRecord)
    }
  }
}
