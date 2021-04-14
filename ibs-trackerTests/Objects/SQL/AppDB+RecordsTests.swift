//
//  AppDB+RecordsTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 22/2/21.
//

import XCTest
@testable import ibs_tracker

class AppDB_RecordsTests: XCTestCase {
  let appDB: AppDB = AppDB.test

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
    try appDB.truncateRecords()
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
      XCTAssertEqual(exportedRecords[i].type, record.type, "The record at index[\(i)] doesn't match the type")
      XCTAssertEqual(exportedRecords[i].timestamp, record.timestamp, "The record at index[\(i)] doesn't match the timestamp")
      XCTAssertEqual(exportedRecords[i].bristolScale, record.bristolScale, "The record at index[\(i)] doesn't match the bristolScale")
      XCTAssertEqual(exportedRecords[i].text, record.text, "The record at index[\(i)] doesn't match the text")
      XCTAssertEqual(exportedRecords[i].size, record.size, "The record at index[\(i)] doesn't match the size")
      XCTAssertEqual(exportedRecords[i].risk, record.risk, "The record at index[\(i)] doesn't match the risk")
      XCTAssertEqual(exportedRecords[i].speed, record.speed, "The record at index[\(i)] doesn't match the speed")
      XCTAssertEqual(exportedRecords[i].pain, record.pain, "The record at index[\(i)] doesn't match the pain")
      XCTAssertEqual(exportedRecords[i].bloating, record.bloating, "The record at index[\(i)] doesn't match the bloating")
      XCTAssertEqual(exportedRecords[i].bodyache, record.bodyache, "The record at index[\(i)] doesn't match the bodyache")
      XCTAssertEqual(exportedRecords[i].headache, record.headache, "The record at index[\(i)] doesn't match the headache")
      XCTAssertEqual(exportedRecords[i].feel, record.feel, "The record at index[\(i)] doesn't match the feel")
      XCTAssertEqual(exportedRecords[i].stress, record.stress, "The record at index[\(i)] doesn't match the stress")
      XCTAssertEqual(exportedRecords[i].medicationType, record.medicationType, "The record at index[\(i)] doesn't match the medicationType")
      XCTAssertEqual(exportedRecords[i].weight, record.weight, "The record at index[\(i)] doesn't match the weight")
      XCTAssertEqual(exportedRecords[i].condition, record.condition, "The record at index[\(i)] doesn't match the skin condition")
      XCTAssertEqual(exportedRecords[i].medicinal, record.medicinal, "The record at index[\(i)] doesn't match the medicinal boolean")
      XCTAssertEqual(exportedRecords[i].tags, record.tags, "The record at index[\(i)] doesn't match the tags")

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
    XCTAssertEqual(ibsRecordCount, 13, "No ibs records imported")

    let ibsTagRecordCount = try appDB.countRecords(in: SQLIBSTagRecord.self)
    XCTAssertEqual(ibsTagRecordCount, 14, "No ibs-tag records imported")

    let tagRecordCount = try appDB.countRecords(in: SQLTagRecord.self)
    XCTAssertEqual(tagRecordCount, 12, "No tag records imported")
  }

  func testAppDBImportRecords() throws {
    let bundle = Bundle(for: type(of: self))
    let dataSet = try bundle.decode(DataSet.self, from: "records-to-import.json")
    try appDB.importRecords(dataSet.ibsRecords)

    let ibsRecordCount = try appDB.countRecords(in: SQLIBSRecord.self)
    XCTAssertEqual(ibsRecordCount, 13, "No ibs records imported")

    let ibsTagRecordCount = try appDB.countRecords(in: SQLIBSTagRecord.self)
    XCTAssertEqual(ibsTagRecordCount, 14, "No ibs-tag records imported")

    let tagRecordCount = try appDB.countRecords(in: SQLTagRecord.self)
    XCTAssertEqual(tagRecordCount, 12, "No tag records imported")
  }

  func testPerformanceExportRecords() throws {
    let records: [IBSRecord] = Array(0..<200).map {
      let datetime = Date.init(timeIntervalSinceReferenceDate: Double($0) * 300)
      let randomTag = String((0..<10).map{ _ in "ab".randomElement()! })
      return IBSRecord(
        bristolScale: .b4,
        timestamp: datetime,
        tags: ["No wiping required", "Ghosty", randomTag]
      )
    }

    try appDB.importRecords(records)

    self.measure {
      do {
        _ = try appDB.exportRecords()
      } catch {
        print("Couldn't export records")
      }
    }
  }

}
