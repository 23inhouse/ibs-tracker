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

  func testPerformanceExportRecords() throws {
    let records: [IBSRecord] = Array(0..<200).map {
      let datetime = Date.init(timeIntervalSinceReferenceDate: Double($0) * 300)
      let randomTag = String((0..<10).map{ _ in "ab".randomElement()! })
      return IBSRecord(
        bristolScale: 4,
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
