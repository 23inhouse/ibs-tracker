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
    ].reversed()

    let today = IBSData.timeShiftedDate()
    let records:[IBSRecord] = meals.map { (time, _) in
      let mealTime = today.advanced(by: time * 60 * 60)
      return IBSRecord(timestamp: mealTime, food: "meal", risk: nil, size: nil, speed: nil)
    }
    let dayRecord = DayRecord(date: today, records: records)

    XCTAssertEqual(dayRecord.records.count, 3, "wrong number records")

    let metaRecords = dayRecord.records

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
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
    let meals:[(Double, MealType)] = [
      (11, .breakfast),
      (13, .breakfast),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsBreakfastAndLunch() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (14, .lunch),
    ].reversed()
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
    ].reversed()
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
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsAllMealsTypes() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (11, .breakfast),
      (13, .lunch),
      (16, .lunch),
      (19, .dinner),
      (21, .snack),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsEveryHour() throws {
    let meals:[(Double, MealType)] = [
      (05, .breakfast), // 22
      (06, .breakfast), // 21
      (07, .breakfast), // 20
      (08, .breakfast), // 19
      (09, .breakfast), // 18
      (10, .breakfast), // 17
      (11, .lunch),     // 16
      (12, .lunch),     // 15
      (13, .lunch),     // 14
      (14, .lunch),     // 13
      (15, .lunch),     // 12
      (16, .lunch),     // 11
      (17, .dinner),    // 10
      (18, .dinner),    // 9
      (19, .dinner),    // 8
      (20, .dinner),    // 7
      (21, .dinner),    // 6
      (22, .dinner),    // 5
      (23, .dinner),    // 4
      (24, .snack),     // 3
      (25, .snack),     // 2
      (26, .snack),     // 1
      (27, .snack),     // 0
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsEveryHourBetween8and22() throws {
    let meals:[(Double, MealType)] = [
      (08, .breakfast), // 14
      (09, .breakfast), // 13
      (10, .breakfast), // 12
      (11, .breakfast), // 11
      (12, .lunch),     // 10
      (13, .lunch),     // 9
      (14, .lunch),     // 8
      (15, .lunch),     // 7
      (16, .dinner),    // 6
      (17, .dinner),    // 5
      (18, .dinner),    // 4
      (19, .dinner),    // 3
      (20, .snack),     // 2
      (21, .snack),     // 1
      (22, .snack),     // 0
    ].reversed()
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
      (12, .lunch),     // 3
      (13, .lunch),     // 4
      (14, .lunch),     // 5
      (15, .lunch),     // 6
      (16, .dinner),    // 7
      (17, .dinner),    // 8
      (18, .dinner),    // 9
      (19, .dinner),    // 10
    ].reversed()
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
      (23, .snack),
    ].reversed()
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
      (25, .snack),
    ].reversed()
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
      (23.5, .snack),
    ].reversed()
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
    ].reversed()
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
    ].reversed()
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
      (16, .lunch),
      (16.166, .lunch),
      (21.75, .snack),
      (22.166, .snack),
    ].reversed()
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
      (20.833, .snack),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_03() throws {
    let meals:[(Double, MealType)] = [
      (11.416, .breakfast),
      (16.166, .lunch),
      (16.416, .lunch),
      (19, .dinner),
      (21.333, .dinner),
      (21.666, .dinner),
      (24, .snack),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_19() throws {
    let meals:[(Double, MealType)] = [
      (8.33, .breakfast),
      (10, .breakfast),
      (16.25, .lunch),
      (19.25, .dinner),
      (21, .dinner),
      (22.666, .snack),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_03_27() throws {
    let meals:[(Double, MealType)] = [
      (9, .breakfast),
      (14.5, .lunch),
      (16.666, .lunch),
      (16.833, .lunch),
      (16.916, .lunch),
      (18.416, .dinner),
      (19, .dinner),
      (24.166, .snack),
    ].reversed()
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
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, expectation)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, expectation, "wrong meal type at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_01() throws {
    let meals:[(Double, MealType, Scales?, Scales?, Scales?)] = [
      (11, .breakfast, nil, nil, nil),
      (12.833, .breakfast, nil, .mild, nil),
      (15.583, .lunch, nil, nil, .moderate),
      (19.416, .dinner, nil, nil, .zero),
      (19.666, .dinner, nil, nil, nil),
      (22, .dinner, .severe, .moderate, nil),
      (24.333, .snack, .extreme, nil, .severe),
      (24.416, .snack, .extreme, nil, nil),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, mealType, mealTooLate, mealTooLong, mealToosoon)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, mealType, "wrong meal type at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooLate, mealTooLate, "wrong meal too late at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooLong, mealTooLong, "wrong meal too long at index [\(i)]")
      XCTAssertEqual(metaRecords[i].mealTooSoon, mealToosoon, "wrong meal too soon at index [\(i)]")
    }
  }

  func testCalcFoodMetaRecordsComplicated_2021_04_09() throws {
    let meals:[(Double, MealType)] = [
      (9.833, .breakfast),
      (11.083, .breakfast),
      (13.666, .lunch),
      (16.583, .lunch),
      (20, .dinner),
      (20.416, .dinner),
    ].reversed()
    let hours = meals.map { $0.0 }
    let metaRecords = calcMetaRecords(for: hours)

    for (i, (_, mealType)) in meals.enumerated() {
      XCTAssertEqual(metaRecords[i].mealType ?? MealType.none, mealType, "wrong meal type at index [\(i)]")
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
    ].reversed()
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
      (24.583, .snack),
    ].reversed()
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
    ].reversed()
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
    let dayRecord = DayRecord(date: today, records: records)
    return dayRecord.records
  }
}

