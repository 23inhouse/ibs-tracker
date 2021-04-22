//
//  IBSRecord+FoodRecordTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 1/5/21.
//

import XCTest
@testable import ibs_tracker

class IBSRecord_FoodRecordTests: XCTestCase {
  func testDurationInMinutes() throws {
    let expections: [(FoodSizes, Scales, Double)] = [
      (.small,   .zero,     22.5),
      (.small,   .mild,     15),
      (.small,   .moderate, 11.3),
      (.small,   .severe,    4.1),
      (.small,   .extreme,   1.5),
      (.normal,  .zero,     30),
      (.normal,  .mild,     20),
      (.normal,  .moderate, 15),
      (.normal,  .severe,    5.5),
      (.normal,  .extreme,   2),
      (.large,   .zero,     37.5),
      (.large,   .mild,     25),
      (.large,   .moderate, 18.8),
      (.large,   .severe,    6.8),
      (.large,   .extreme,   2.5),
      (.huge,    .zero,     45),
      (.huge,    .mild,     30),
      (.huge,    .moderate, 22.5),
      (.huge,    .severe,    8.2),
      (.huge,    .extreme,   3),
      (.extreme, .zero,     52.5),
      (.extreme, .mild,     35),
      (.extreme, .moderate, 26.3),
      (.extreme, .severe,    9.5),
      (.extreme, .extreme,   3.5),
    ]

    for (size, speed, expectedDuration) in expections {
      let record = IBSRecord(timestamp: Date(), food: "meal", risk: nil, size: size, speed: speed)
      let duration = record.durationInMinutes
      XCTAssertEqual(duration, expectedDuration, "Wrong duration for speed [\(speed)] & size [\(size)]")
    }
  }
}
