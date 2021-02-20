//
//  Date+NearestTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 14/2/21.
//

import XCTest
@testable import ibs_tracker

class Date_NearestTests: XCTestCase {
  func testNearestRoundingUp() throws {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS Z"
    var time = formatter.date(from: "2016-10-08 22:32:30.1111 +0000")
    let expectedTime = formatter.date(from: "2016-10-08 22:35:00.0000 +0000")

    time = time?.nearest(5, .minute)
    XCTAssertEqual(time, expectedTime, "Should round up to the nearest 5 minutes with no seconds or nanoseconds")
  }

  func testNearestRoundingDown() throws {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS Z"
    var time = formatter.date(from: "2016-10-08 22:42:29.9999 +0000")
    let expectedTime = formatter.date(from: "2016-10-08 22:40:00.0000 +0000")

    time = time?.nearest(5, .minute)
    XCTAssertEqual(time, expectedTime, "Should round down to the nearest 5 minutes with no seconds or nanoseconds")
  }

  func testNearestRoundingNoChange() throws {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS Z"
    var time = formatter.date(from: "2016-10-08 22:45:00.0000 +0000")
    let expectedTime = formatter.date(from: "2016-10-08 22:45:00.0000 +0000")

    time = time?.nearest(5, .minute)
    XCTAssertEqual(time, expectedTime, "Should round to the nearest 5 minutes with no seconds or nanoseconds")
  }
}
