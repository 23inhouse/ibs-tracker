//
//  ibs_trackerUITests.swift
//  ibs-trackerUITests
//
//  Created by Benjamin Lewis on 12/1/21.
//

import XCTest

class ibs_trackerUITests: XCTestCase {
  override func setUpWithError() throws {
    continueAfterFailure = false
  }

  override func tearDownWithError() throws {
  }

  func testExample() throws {
    let app = XCUIApplication()
    app.launch()
  }

  func testLaunchPerformance() throws {
    if #available(iOS 14.0, *) {
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
