//
//  IBSRecord+GRDBTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 16/2/21.
//

import XCTest
@testable import ibs_tracker

class IBSRecord_GRDBTests: XCTestCase {
  let appDB: AppDB = AppDB.test

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
    try appDB.truncateRecords()
  }

  func testDeleteSQL() throws {
    let ibsRecord = IBSRecord(bristolScale: .b4, timestamp: Date())
    try ibsRecord.insertSQL(into: appDB)

    try ibsRecord.deleteSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 0, "There should be no records")
  }

  func testInsertSQL() throws {
    let ibsRecord = IBSRecord(bristolScale: .b4, timestamp: Date())
    try ibsRecord.insertSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")
  }

  func testInsertSQLInvalid() throws {
    let date = Date()
    let ibsRecord = IBSRecord(bristolScale: .b4, timestamp: date)
    try ibsRecord.insertSQL(into: appDB)

    let invalidIBSRecord = IBSRecord(bristolScale: .b3, timestamp: date)

    XCTAssertThrowsError(try invalidIBSRecord.insertSQL(into: appDB), "Should throw an error")

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")
  }

  func testInsertSQLWithNegativeScales() throws {
    let timestamp = Date()

    let ibsAcheRecord = IBSRecord(timestamp: timestamp, headache: Scales.none, bodyache: Scales.none)
    try ibsAcheRecord.insertSQL(into: appDB)
    guard var sqlIBSAcheRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: "ache", at: timestamp) else {
      throw "Couldn't select the orignal BM record"
    }

    XCTAssertEqual(sqlIBSAcheRecord.headache, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSAcheRecord.bodyache, nil, "The scale should be nil")

    sqlIBSAcheRecord.update(from: ibsAcheRecord)

    XCTAssertEqual(sqlIBSAcheRecord.headache, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSAcheRecord.bodyache, nil, "The scale should be nil")

    let ibsBMRecord = IBSRecord(bristolScale: nil, timestamp: timestamp, tags: [], color: nil, pressure: Scales.none, smell: nil, evacuation: nil, dryness: Scales.none, wetness: Scales.none)
    try ibsBMRecord.insertSQL(into: appDB)
    guard var sqlIBSBMRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: ibsBMRecord.type.rawValue, at: timestamp) else {
      throw "Couldn't select the orignal BM record"
    }

    XCTAssertEqual(sqlIBSBMRecord.pressure, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSBMRecord.dryness, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSBMRecord.wetness, nil, "The scale should be nil")

    sqlIBSBMRecord.update(from: ibsBMRecord)

    XCTAssertEqual(sqlIBSBMRecord.pressure, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSBMRecord.dryness, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSBMRecord.wetness, nil, "The scale should be nil")


    let ibsGutRecord = IBSRecord(timestamp: timestamp, bloating: Scales.none, pain: Scales.none)
    try ibsGutRecord.insertSQL(into: appDB)
    guard var sqlIBSGutRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: ibsGutRecord.type.rawValue, at: timestamp) else {
      throw "Couldn't select the orignal BM record"
    }

    XCTAssertEqual(sqlIBSGutRecord.bloating, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSGutRecord.pain, nil, "The scale should be nil")

    sqlIBSGutRecord.update(from: ibsGutRecord)

    XCTAssertEqual(sqlIBSGutRecord.bloating, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSGutRecord.pain, nil, "The scale should be nil")

    let ibsFoodRecord = IBSRecord(food: "Pizza", timestamp: timestamp, risk: Scales.none, size: FoodSizes.none)
    try ibsFoodRecord.insertSQL(into: appDB)
    guard var sqlIBSFoodRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: ibsFoodRecord.type.rawValue, at: timestamp) else {
      throw "Couldn't select the orignal BM record"
    }

    XCTAssertEqual(sqlIBSFoodRecord.risk, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSFoodRecord.size, nil, "The scale should be nil")

    sqlIBSFoodRecord.update(from: ibsFoodRecord)

    XCTAssertEqual(sqlIBSFoodRecord.risk, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSFoodRecord.size, nil, "The scale should be nil")

    let ibsMoodRecord = IBSRecord(timestamp: timestamp, feel: MoodType.none, stress: Scales.none)
    try ibsMoodRecord.insertSQL(into: appDB)
    guard var sqlIBSMoodRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: ibsMoodRecord.type.rawValue, at: timestamp) else {
      throw "Couldn't select the orignal BM record"
    }

    XCTAssertEqual(sqlIBSMoodRecord.feel, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSMoodRecord.stress, nil, "The scale should be nil")

    sqlIBSMoodRecord.update(from: ibsMoodRecord)

    XCTAssertEqual(sqlIBSMoodRecord.feel, nil, "The scale should be nil")
    XCTAssertEqual(sqlIBSMoodRecord.stress, nil, "The scale should be nil")
  }

  func testUpdateSQL() throws {
    let recordTypeStrng = ItemType.bm.rawValue
    let originalBristolScale = BristolType.b4
    let newBristolScale = BristolType.b3

    var ibsRecord = IBSRecord(bristolScale: originalBristolScale, timestamp: Date())
    try ibsRecord.insertSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")

    let timestamp = ibsRecord.timestamp
    ibsRecord.bristolScale = newBristolScale

    guard let sqlIBSRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: recordTypeStrng, at: timestamp) else {
      throw "Couldn't select the orignal record"
    }

    XCTAssertEqual(sqlIBSRecord.bristolScale, originalBristolScale.rawValue, "The scale should still be the orginal value of 4")
    try ibsRecord.updateSQL(into: appDB, timestamp: timestamp)

    guard let newSQLIBSRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: recordTypeStrng, at: timestamp) else {
      throw "Couldn't select the updated record"
    }
    XCTAssertEqual(newSQLIBSRecord.bristolScale, newBristolScale.rawValue, "The scale should be the new value of 3")

    let newIBSRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(newIBSRecordCount, 1, "There should still only be 1 record")
  }

  func testUpdateSQLChangeTheTimestamp() throws {
    let recordTypeStrng = ItemType.bm.rawValue

    var ibsRecord = IBSRecord(bristolScale: .b3, timestamp: Date())
    try ibsRecord.insertSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")

    let timestamp = ibsRecord.timestamp
    guard let sqlIBSRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: recordTypeStrng, at: timestamp) else {
      throw "Couldn't select the orignal record"
    }

    XCTAssertEqual(sqlIBSRecord.timestamp.timestampString(), timestamp.timestampString(), "The time should be the original timestamp")

    let newTimestamp = timestamp.addingTimeInterval(60)
    ibsRecord.timestamp = newTimestamp
    try ibsRecord.updateSQL(into: appDB, timestamp: timestamp)

    guard let newSQLIBSRecord = try appDB.selectRecord(in: SQLIBSRecord.self, of: recordTypeStrng, at: newTimestamp) else {
      throw "Couldn't select the updated record"
    }
    XCTAssertEqual(newSQLIBSRecord.bristolScale, 3, "The scale should still be the old value of 3")
    XCTAssertEqual(newSQLIBSRecord.timestamp.timestampString(), newTimestamp.timestampString(), "The time should be the new timestamp")

    let newIBSRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(newIBSRecordCount, 1, "There should still only be 1 record")
  }

  func testValidTagNames() throws {
    let invalidTags = ["Very|Good", "You|had|to|be|there"]
    let validTags = ["Very--Good", "You--had--to--be--there"]

    var calender = Calendar.current
    calender.timeZone = TimeZone(abbreviation: "UTC")!
    let date = calender.startOfDay(for: Date())
    let ibsRecord = IBSRecord(bristolScale: .b3, timestamp: date, tags: invalidTags)
    try ibsRecord.insertSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")

    let insertedRecords = try appDB.exportRecords()

    XCTAssertEqual(insertedRecords.count, 1, "There should be 1 record")

    var exportedRecord = insertedRecords.first!
    XCTAssertEqual(exportedRecord.tags, validTags, "The tags should have the pipes removed")

    exportedRecord.tags = invalidTags

    try exportedRecord.updateSQL(into: appDB, timestamp: exportedRecord.timestamp)

    let updatedRecords = try appDB.exportRecords()

    XCTAssertEqual(updatedRecords.count, 1, "There should be 1 record")

    exportedRecord = updatedRecords.first!
    XCTAssertEqual(exportedRecord.tags, validTags, "The tags should have the pipes removed")
  }
}
