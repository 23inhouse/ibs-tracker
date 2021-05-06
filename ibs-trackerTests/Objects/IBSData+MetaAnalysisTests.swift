//
//  IBSData+MetaAnalysisTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 21/4/21.
//

import XCTest
@testable import ibs_tracker

class IBSData_MetaAnalysisTests: XCTestCase {
  func testCalcMetaRecords() throws {
    let eightOClock: Double = 60 * 60 * 8
    let today = IBSData.timeShiftedDate()
    let timestamp = today.addingTimeInterval(eightOClock)
    let records = [
      IBSRecord(timestamp: timestamp, note: "note 1"),
      IBSRecord(timestamp: timestamp, food: "breakfast", risk: nil, size: nil, speed: nil),
      IBSRecord(timestamp: timestamp, note: "note 3"),
    ]
    let ibsData = IBSData(records)

    XCTAssertEqual(ibsData.savedRecords.count, 3, "wrong number records")
    XCTAssertEqual(ibsData.computedRecords.count, 3, "wrong number records")
    XCTAssertEqual(ibsData.recordsByDay.first!.records.count, 3, "wrong number records")
    XCTAssertEqual(ibsData.computedRecords[1].type, .food, "wrong record type")
    XCTAssertEqual(ibsData.computedRecords[1].mealType, .breakfast, "wrong meal type")
  }

  func testCalcBMMetaRecords() throws {
    let oneDay: Double = 60 * 60 * 24 * 1
    let eightOClock: Double = 60 * 60 * 8
    let today = IBSData.timeShiftedDate()
    let yesterday = today.advanced(by: -oneDay + eightOClock)
    let records = [
      IBSRecord(timestamp: yesterday, note: "note 1"),
    ]
    let ibsData = IBSData(records)

    XCTAssertEqual(ibsData.savedRecords.count, 1, "wrong number records")
    XCTAssertEqual(ibsData.computedRecords.count, 2, "wrong number records")
    XCTAssertEqual(ibsData.recordsByDay.first!.records.count, 2, "wrong number records")

    let bmRecord = ibsData.computedRecords.first!
    let noteRecord = ibsData.computedRecords.last!
    XCTAssertEqual(bmRecord.type, .bm, "wrong type of record")
    XCTAssertEqual(bmRecord.bristolScale, .b0, "wrong type of bm")
    XCTAssertEqual(noteRecord.type, .note, "wrong type of record")
  }

  func testCalcFoodMetaRecords() throws {
    let meals:[(Double, MealType)] = [
      (8, .breakfast),
      (13, .lunch),
      (19, .dinner),
    ]

    let today = IBSData.timeShiftedDate()
    let records:[IBSRecord] = meals.map { (time, _) in
      let mealTime = today.advanced(by: time * 60 * 60)
      return IBSRecord(timestamp: mealTime, food: "meal", risk: nil, size: nil, speed: nil)
    }
    let ibsData = IBSData(records)

    XCTAssertEqual(ibsData.savedRecords.count, 3, "wrong number records")
    XCTAssertEqual(ibsData.computedRecords.count, 3, "wrong number records")
    XCTAssertEqual(ibsData.recordsByDay.first!.records.count, 3, "wrong number records")

    let computedRecords = ibsData.computedRecords

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(computedRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsIncludingMedicinalFoodRecord() throws {
    let meals:[(Double, MealType, Bool)] = [
      (10.583, .breakfast, false),
      (14.75, .lunch, false),
      (15, .none, true),
      (18.416, .dinner, false),
      (18.666, .dinner, false),
      (20.916, .snack1, false),
      (24.916, .snack2, false),
    ]

    let today = IBSData.timeShiftedDate()
    let records:[IBSRecord] = meals.map { (time, _, medicinal) in
      let mealTime = today.advanced(by: time * 60 * 60)
      return IBSRecord(timestamp: mealTime, food: "meal", risk: nil, size: nil, speed: nil, medicinal: medicinal)
    }
    let ibsData = IBSData(records)

    let computedRecords = Array(ibsData.recordsByDay.first!.records.reversed())

    for (i, (_, expectation, _)) in meals.enumerated() {
      XCTAssertEqual(computedRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }
}
