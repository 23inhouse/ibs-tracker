//
//  DayRecordTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 30/4/21.
//

import XCTest
@testable import ibs_tracker

class DayRecordTests: XCTestCase {
  func testCalcMetaRecords() throws {
    let eightOClock: Double = 60 * 60 * 8
    let today = IBSData.timeShiftedDate()
    let timestamp = today.addingTimeInterval(eightOClock)
    let records = [
      IBSRecord(timestamp: timestamp, note: "note 1"),
      IBSRecord(timestamp: timestamp, food: "breakfast", risk: nil, size: nil, speed: nil),
      IBSRecord(timestamp: timestamp, note: "note 3"),
    ]
    let dayRecord = DayRecord(date: today, records: records)

    XCTAssertEqual(dayRecord.records.count, 3, "wrong number records")
    XCTAssertEqual(dayRecord.records[1].type, .food, "wrong record type")
    XCTAssertEqual(dayRecord.records[1].mealType, .breakfast, "wrong meal type")
  }

  func testCalcBMMetaRecords() throws {
    let hour: Double = 60 * 60
    let oneDay: Double = 24 * hour
    let eightOClock: Double = 8 * hour
    let today = IBSData.timeShiftedDate()
    let yesterday = today.advanced(by: -oneDay + eightOClock)
    let records = [
      IBSRecord(timestamp: yesterday, note: "note 1"),
    ]
    let dayRecord = DayRecord(date: yesterday, records: records)

    XCTAssertEqual(dayRecord.records.count, 2, "wrong number records")

    let bmRecord = dayRecord.records.first!
    let noteRecord = dayRecord.records.last!
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
    let dayRecord = DayRecord(date: today, records: records.reversed())

    XCTAssertEqual(dayRecord.records.count, 3, "wrong number records")

    let metaRecords = Array(dayRecord.records.reversed())

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealStart, true, "wrong meal start at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealEnd, true, "wrong meal end at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsBreakfastOnly() throws {
    let today = IBSData.timeShiftedDate()
    let breakfastTime = today.advanced(by: 16 * 60 * 60)
    let records = [
      IBSRecord(timestamp: breakfastTime, food: "breakfast", risk: nil, size: nil, speed: nil),
    ]
    let dayRecord = DayRecord(date: today, records: records)

    let breakfastRecord = dayRecord.records[0]
    XCTAssertEqual(breakfastRecord.mealType ?? MealType.none, .breakfast, "wrong meal type")
  }

  func testCalcFoodMetaRecordsLongBreakfast() throws {
    let meals:[(Double, MealType, Bool?, Bool?)] = [
      (11, .breakfast, true, nil),
      (12, .breakfast, nil, nil),
      (13, .breakfast, nil, true),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, mealType, mealStart, mealEnd)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, mealType, "wrong meal type at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealStart, mealStart, "wrong meal start at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealEnd, mealEnd, "wrong meal end at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsBreakfastAndLunch() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (14, .lunch),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsBreakfastLunchAndDinner() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (13, .lunch),
      (19, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsBreakfastLunchAndDinnerDoubled() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (10, .breakfast),
      (13, .lunch),
      (14, .lunch),
      (19, .dinner),
      (20, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsBreakfastAndDinner() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (19, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsAllMealsTypes() throws {
    let meals:[(Double, MealType)] = [ // 13
      (9, .breakfast),
      (11, .breakfast),
      (14, .lunch),
      (16, .lunch),
      (19, .dinner),
      (22, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsEveryHour() throws {
    let meals:[(Double, MealType)] = [
      (05, .breakfast), // 0
      (06, .breakfast), // 1
      (07, .breakfast), // 2
      (08, .breakfast), // 3
      (09, .breakfast), // 4
      (10, .breakfast), // 5
      (11, .lunch),     // 6
      (12, .lunch),     // 7
      (13, .lunch),     // 8
      (14, .lunch),     // 9
      (15, .lunch),     // 10
      (16, .lunch),     // 11
      (17, .lunch),     // 12
      (18, .dinner),    // 13
      (19, .dinner),    // 14
      (20, .dinner),    // 15
      (21, .dinner),    // 16
      (22, .dinner),    // 17
      (23, .dinner),    // 18
      (24, .lateMeal),  // 19
      (25, .lateMeal),  // 20
      (26, .lateMeal),  // 21
      (27, .lateMeal),  // 22
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsEveryHourBetween8and22() throws {
    let meals:[(Double, MealType)] = [
      (08, .breakfast), // 0
      (09, .breakfast), // 1
      (10, .breakfast), // 2
      (11, .breakfast), // 3
      (12, .lunch),     // 4
      (13, .lunch),     // 5
      (14, .lunch),     // 6
      (15, .lunch),     // 7
      (16, .dinner),    // 8
      (17, .dinner),    // 9
      (18, .dinner),    // 10
      (19, .dinner),    // 11
      (20, .lateMeal),  // 12
      (21, .lateMeal),  // 13
      (22, .lateMeal),  // 14
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsEveryHourBetween9and19() throws {
    let meals:[(Double, MealType)] = [
      (09, .breakfast), // 0
      (10, .breakfast), // 1
      (11, .breakfast), // 2
      (12, .breakfast), // 3
      (13, .lunch),     // 4
      (14, .lunch),     // 5
      (15, .lunch),     // 6
      (16, .dinner),    // 7
      (17, .dinner),    // 8
      (18, .dinner),    // 9
      (19, .dinner),    // 10
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsLateBreakfast() throws {
    let meals:[(Double, MealType)] = [
      (10, .breakfast),
      (13.5, .lunch),
      (19, .dinner),
      (23, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2020_09_11() throws {
    let meals:[(Double, MealType)] = [
      (11.166, .breakfast),
      (15.166, .lunch),
      (20, .dinner),
      (20.33, .dinner),
      (25, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2020_09_13() throws {
    let meals:[(Double, MealType)] = [
      (12.416, .breakfast),
      (15.5, .lunch),
      (19.25, .dinner),
      (20.833, .dinner),
      (23.5, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_01_22() throws {
    let meals:[(Double, MealType)] = [ // 11.833
      (9, .breakfast),
      (10.5, .breakfast),
      (13.416, .lunch),
      (20.083, .dinner),
      (20.833, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_02_11() throws {
    let meals:[(Double, MealType)] = [
      (14, .breakfast),
      (15.833, .lunch),
      (16.083, .lunch),
      (20.583, .dinner),
      (20.916, .dinner),
      (21, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_02_19() throws {
    let meals:[(Double, MealType)] = [ // 12.75
      (9.416, .breakfast),
      (12.75, .lunch),
      (16, .dinner),
      (16.166, .dinner),
      (21.75, .lateMeal),
      (22.166, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_02_26() throws {
    let meals:[(Double, MealType)] = [ // 13.417
      (7.416, .breakfast),
      (7.5, .breakfast),
      (11, .lunch),
      (15.166, .dinner),
      (15.5, .dinner),
      (20.833, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_03() throws {
    let meals:[(Double, MealType)] = [ // 14.916
      (11.416, .breakfast),
      (16.166, .lunch),
      (16.416, .lunch),
      (19, .dinner),
      (21.333, .lateMeal),
      (21.666, .lateMeal),
      (24, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_19() throws {
    let meals:[(Double, MealType)] = [ // 14.333
      (8.333, .breakfast),
      (10, .breakfast),
      (16.25, .lunch),
      (19.25, .dinner),
      (21, .dinner),
      (22.666, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_27() throws {
    let meals:[(Double, MealType)] = [ // 14.916
      (9, .breakfast),
      (14.5, .lunch),
      (16.666, .dinner),
      (16.833, .dinner),
      (16.916, .dinner),
      (18.416, .dinner),
      (19, .dinner),
      (24.166, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_28() throws {
    let meals:[(Double, MealType)] = [
      (11.666, .breakfast),
      (15.083, .lunch),
      (19.666, .dinner),
      (19.75, .dinner),
      (20.333, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_01() throws {
    let meals:[(Double, MealType, Scales?, Scales?, Scales?)] = [
      (11, .breakfast, nil, nil, nil),
      (12.833, .breakfast, nil, .moderate, nil),
      (15.583, .lunch, nil, nil, .moderate),
      (19.416, .dinner, nil, nil, .zero),
      (19.666, .dinner, nil, nil, nil),
      (22, .dinner, .severe, .severe, nil),
      (24.333, .lateMeal, .extreme, nil, .severe),
      (24.416, .lateMeal, .extreme, nil, nil),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, mealType, mealTooLate, mealTooLong, mealToosoon)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, mealType, "wrong meal type at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooLate, mealTooLate, "wrong meal too late at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooLong, mealTooLong, "wrong meal too long at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooSoon, mealToosoon, "wrong meal too soon at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_13() throws {
    let meals:[(Double, MealType)] = [ // 14.75
      (10.583, .breakfast),
      (14.75, .lunch),
      (18.416, .dinner),
      (18.666, .dinner),
      (20.916, .dinner),
      (24.916, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_09() throws {
    let meals:[(Double, MealType)] = [ // 10.583
      (9.833, .breakfast),
      (11.083, .breakfast),
      (13.666, .lunch),
      (16.583, .lunch),
      (20, .dinner),
      (20.416, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, mealType)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, mealType, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_11() throws {
    let meals:[(Double, MealType, Scales?, Scales?, Scales?)] = [ // 15.75
      (11.083, .breakfast, nil, nil, nil),
      (12.583, .breakfast, nil, .mild, nil),
      (16.916, .lunch, nil, nil, .zero),
      (18.333, .dinner, nil, nil, .extreme),
      (18.833, .dinner, nil, nil, nil),
      (19.333, .dinner, nil, nil, nil),
      (23.416, .lateMeal, .extreme, nil, .zero),
      (23.833, .lateMeal, .extreme, nil, nil),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, mealType, mealTooLate, mealTooLong, mealToosoon)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, mealType, "wrong meal type at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooLate, mealTooLate, "wrong meal too late at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooLong, mealTooLong, "wrong meal too long at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooSoon, mealToosoon, "wrong meal too soon at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_15() throws {
    let meals:[(Double, MealType)] = [
      (10.5, .breakfast),
      (12.166, .breakfast),
      (16.75, .lunch),
      (17, .lunch),
      (17.666, .lunch),
      (21.166, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_16() throws {
    let meals:[(Double, MealType)] = [ // 10.583
      (10.75, .breakfast),
      (13.083, .breakfast),
      (18.166, .lunch),
      (18.25, .lunch),
      (21.416, .dinner),
      (21.333, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_19() throws {
    let meals:[(Double, MealType)] = [
      (11.166, .breakfast),
      (13.583, .breakfast),
      (18.666, .lunch),
      (18.916, .lunch),
      (19, .lunch),
      (21.083, .dinner),
      (24.583, .lateMeal),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_25() throws {
    let meals:[(Double, MealType)] = [
      (13.833, .breakfast),
      (18.916, .lunch),
      (21.833, .dinner),
      (21.916, .dinner),
      (22.25, .dinner),
      (22.916, .dinner),
    ]
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }
}

private extension DayRecordTests {
  func calcMetaRecords(for hours: [Double]) -> [IBSRecord] {
    let today = IBSData.timeShiftedDate()
    let records:[IBSRecord] = hours.map { hour in
      let mealTime = today.advanced(by: hour * 60 * 60)
      return IBSRecord(timestamp: mealTime, food: "meal", risk: nil, size: nil, speed: nil)
    }
    let dayRecord = DayRecord(date: today, records: records.reversed())
    return dayRecord.records.reversed()
  }
}

