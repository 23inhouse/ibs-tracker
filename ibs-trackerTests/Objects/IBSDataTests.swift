//
//  IBSDataTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 17/2/21.
//

import XCTest
@testable import ibs_tracker

class IBSDataTests: XCTestCase {
  let appDB: AppDB = AppDB.test

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
    try appDB.truncateRecords()
  }

  func testRecentRecords() throws {
    let bundle = Bundle(for: type(of: self))
    let dataSet = try bundle.decode(DataSet.self, from: "records-recent-food.json")
    try appDB.importRecords(dataSet.ibsRecords)

    let ibsData = IBSData(.test)
    let recordCount = ibsData.recentRecords(of: .food).count
    XCTAssertEqual(recordCount, 2, "wrong number records")
  }
}