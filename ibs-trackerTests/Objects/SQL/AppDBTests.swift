//
//  AppDBTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 3/2/21.
//

import XCTest
@testable import ibs_tracker

class AppDBTests: XCTestCase {
  let appDB: AppDB = AppDB.test

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
    try appDB.truncateRecords()
  }

  func testAppDB() throws {
    let expectedTables = [
      "IBSRecords",
      "IBSTagRecords",
      "IBSTags"
    ]

    try appDB.dbWriter.read { db in
      let selectSQL = "SELECT name FROM sqlite_master WHERE type='table'"
      let rows = try String.fetchAll(db, sql: selectSQL)

      for expectedTable in expectedTables {
        XCTAssert(rows.contains(expectedTable), "\(expectedTable) is missing from the migration")
      }
    }
  }
}
