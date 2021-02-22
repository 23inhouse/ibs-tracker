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
    let ibsRecord = IBSRecord(bristolScale: 4, timestamp: Date())
    try ibsRecord.insertSQL(into: appDB)

    try ibsRecord.deleteSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 0, "There should be no records")
  }

  func testInsertSQL() throws {
    let ibsRecord = IBSRecord(bristolScale: 4, timestamp: Date())
    try ibsRecord.insertSQL(into: appDB)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")
  }

  func testInsertSQLInvalid() throws {
    let date = Date()
    let ibsRecord = IBSRecord(bristolScale: 4, timestamp: date)
    try ibsRecord.insertSQL(into: appDB)

    let invalidIBSRecord = IBSRecord(bristolScale: 3, timestamp: date)

    XCTAssertThrowsError(try invalidIBSRecord.insertSQL(into: appDB), "Should throw an error")

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 1, "There should be 1 record")
  }

  func testUpdateSQL() throws {
    let recordTypeStrng = ItemType.bm.rawValue
    let originalBristolScale = BristolType.b4
    let newBristolScale = BristolType.b3

    var ibsRecord = IBSRecord(bristolScale: originalBristolScale.rawValue, timestamp: Date())
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

    var ibsRecord = IBSRecord(bristolScale: 3, timestamp: Date())
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
}
