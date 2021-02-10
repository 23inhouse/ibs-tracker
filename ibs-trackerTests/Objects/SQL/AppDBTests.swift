//
//  AppDBTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 3/2/21.
//

import XCTest
@testable import ibs_tracker

class AppDBTests: XCTestCase {
  func testAppDB() throws {
    let expectedTables = [
      "IBSRecords",
      "IBSTagRecords",
      "IBSTags"
    ]

    let appDB = AppDB.test
    try appDB.dbWriter.read { db in
      let selectSQL = "SELECT name FROM sqlite_master WHERE type='table'"
      let rows = try String.fetchAll(db, sql: selectSQL)

      for expectedTable in expectedTables {
        XCTAssert(rows.contains(expectedTable), "\(expectedTable) is missing from the migration")
      }
    }
  }

  func testAppDBImport() throws {
    let appDB = AppDB.test

    try appDB.truncateRecords()

    let bundle = Bundle(for: type(of: self))
    let allRecords = try bundle.decode([IBSRecord].self, from: "records-to-import.json")
    try appDB.importRecords(allRecords)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 12, "No ibs records imported")

    let ibsTagRecordCount = try appDB.countRecords(in: SQLIBSTagRecord.self)
    XCTAssertEqual(ibsTagRecordCount, 13, "No ibs-tag records imported")

    let tagRecordCount = try appDB.countRecords(in: SQLTagRecord.self)
    XCTAssertEqual(tagRecordCount, 10, "No tag records imported")
  }
}
