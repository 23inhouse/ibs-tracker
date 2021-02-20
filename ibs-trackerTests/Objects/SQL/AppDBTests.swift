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

  func testAppDBExportRecords() throws {
    continueAfterFailure = false

    let bundle = Bundle(for: type(of: self))
    let dataSet = try bundle.decode(DataSet.self, from: "records-to-import.json")
    let importedRecords = dataSet.ibsRecords

    try appDB.importRecords(importedRecords)
    let exportedRecords = try appDB.exportRecords()

    XCTAssertEqual(exportedRecords.count, importedRecords.count, "There should be \(importedRecords.count) exported records")

    for (i, record) in importedRecords.enumerated() {
      XCTAssertEqual(exportedRecords[i], record, "The record at index[\(i)] doesn't match")
    }
  }

  func testAppDBImportJSON() throws {
    let bundle = Bundle(for: type(of: self))
    let dataSet = try bundle.decode(DataSet.self, from: "records-to-import.json")
    _ = DataSet.encode(dataSet)!.url(path: "records-to-be-imported.json")

    let data = "records-to-be-imported.json".dataAtPath()!
    appDB.importJSON(data)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 12, "No ibs records imported")

    let ibsTagRecordCount = try appDB.countRecords(in: SQLIBSTagRecord.self)
    XCTAssertEqual(ibsTagRecordCount, 13, "No ibs-tag records imported")

    let tagRecordCount = try appDB.countRecords(in: SQLTagRecord.self)
    XCTAssertEqual(tagRecordCount, 10, "No tag records imported")
  }

  func testAppDBImportRecords() throws {
    let bundle = Bundle(for: type(of: self))
    let dataSet = try bundle.decode(DataSet.self, from: "records-to-import.json")
    try appDB.importRecords(dataSet.ibsRecords)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 12, "No ibs records imported")

    let ibsTagRecordCount = try appDB.countRecords(in: SQLIBSTagRecord.self)
    XCTAssertEqual(ibsTagRecordCount, 13, "No ibs-tag records imported")

    let tagRecordCount = try appDB.countRecords(in: SQLTagRecord.self)
    XCTAssertEqual(tagRecordCount, 10, "No tag records imported")
  }
}
