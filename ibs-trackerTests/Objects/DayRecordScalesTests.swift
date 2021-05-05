//
//  DayRecordScalesTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 5/5/21.
//

import XCTest
@testable import ibs_tracker

class DayRecordScalesTests: XCTestCase {
  func testCalcMealTooLate() throws {
    let expectations: [(Double, Scales?)] = [
      (18.0, nil),
      (18.5, nil),
      (19.0, nil),
      (19.5, nil),
      (20.0, .mild),
      (20.5, .mild),
      (21.0, .moderate),
      (21.5, .moderate),
      (22.0, .severe),
      (22.5, .severe),
      (23.0, .extreme),
      (23.5, .extreme),
      (24.0, .extreme),
      (24.5, .extreme),
      (25.0, .extreme),
      (25.5, .extreme),
    ]

    let date = Date().date()
    let hour: Double = 60 * 60
    for (i, (hours, expectation)) in expectations.enumerated() {
      let scale = DayRecordScales.calcMealTooLate(from: date + hours * hour)
      XCTAssertEqual(scale, expectation, "wrong scale at index [\(i)]")
    }
  }

  func testCalcMealTooLong() throws {
    let expectations: [(Double, Scales?)] = [
      (0.5, nil),
      (1.0, nil),
      (1.5, .mild),
      (2.0, .moderate),
      (2.5, .severe),
      (3.0, .extreme),
      (3.5, .extreme),
    ]

    let hour: Double = 60 * 60
    for (i, (hours, expectation)) in expectations.enumerated() {
      let scale = DayRecordScales.calcMealTooLong(from: hours * hour)
      XCTAssertEqual(scale, expectation, "wrong scale at index [\(i)]")
    }
  }

  func testCalcMealTooSoon() throws {
    let expectations: [(Double, Scales)] = [
      (4.0, .zero),
      (3.5, .zero),
      (3.0, .mild),
      (2.5, .moderate),
      (2.0, .severe),
      (1.5, .extreme),
      (1.0, .extreme),
    ]

    let hour: Double = 60 * 60
    for (i, (hours, expectation)) in expectations.enumerated() {
      let scale = DayRecordScales.calcMealTooSoon(from: hours * hour)
      XCTAssertEqual(scale, expectation, "wrong scale at index [\(i)]")
    }
  }
}
