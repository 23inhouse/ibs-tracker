//
//  IBSRecord+DecodableTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 10/2/21.
//

import XCTest
@testable import ibs_tracker

class IBSRecord_DecodableTests: XCTestCase {

  func testTimestamp() throws {
    let timestampString = "2020-10-31 21:45:19+00:00"
    let expectDate = Date(timeIntervalSince1970: 1604180719)

    let timestamp = try IBSRecord.timestamp(from: timestampString)
    XCTAssertEqual(timestamp, expectDate, "Wrong timestamp")
  }

  func testDecode() throws {
    let bundle = Bundle(for: type(of: self))

    let ibsRecords = try bundle.decode([IBSRecord].self, from: "records-to-import.json")
    XCTAssertEqual(ibsRecords.count, 12, "No ibs records imported")

    XCTAssertEqual(ibsRecords[0].type, .gut, "Should be a gut record")
    XCTAssertEqual(ibsRecords[0].bloating, 2, "Bloating should equal 2")

    XCTAssertEqual(ibsRecords[1].type, .gut, "Should be a gut record")
    XCTAssertEqual(ibsRecords[1].bloating, 2, "Bloating should equal 2")

    XCTAssertEqual(ibsRecords[2].type, .food, "Should be a food record")
    XCTAssertEqual(ibsRecords[2].text, "Chips & peanut butter", "Text should equal Chips & peanut butter")

    XCTAssertEqual(ibsRecords[3].type, .ache, "Should be a ache record")
    XCTAssertEqual(ibsRecords[3].headache, 2, "Headache should equal 2")

    XCTAssertEqual(ibsRecords[4].type, .mood, "Should be a mood record")
    XCTAssertEqual(ibsRecords[4].feel, 1, "Feel should equal 1")
    XCTAssertEqual(ibsRecords[4].stress, 1, "Stress should equal 1")

    XCTAssertEqual(ibsRecords[5].type, .medication, "Should be a medication record")
    XCTAssertEqual(ibsRecords[5].medicationType, .antimicrobial, "Medication type should equal antimicrobial")

    XCTAssertEqual(ibsRecords[6].type, .bm, "Should be a bm record")
    XCTAssertEqual(ibsRecords[6].bristolScale, 5, "Bristol scale should equal 5")

    XCTAssertEqual(ibsRecords[7].type, .note, "Should be a note record")
    XCTAssertEqual(ibsRecords[7].text, "See diary", "Text should equal See diary")

    XCTAssertEqual(ibsRecords[8].type, .bm, "Should be a bm record")
    XCTAssertEqual(ibsRecords[8].bristolScale, 6, "Bristol scale should equal 6")

    XCTAssertEqual(ibsRecords[9].type, .food, "Should be a food record")
    XCTAssertEqual(ibsRecords[9].text, "Chips", "Text should equal Chips")

    XCTAssertEqual(ibsRecords[10].type, .weight, "Should be a weight record")
    XCTAssertEqual(ibsRecords[10].weight, 60.8, "Weight should equal 60.8")

    XCTAssertEqual(ibsRecords[11].type, .ache, "Should be a ache record")
    XCTAssertEqual(ibsRecords[11].bodyache, 2, "Bodyache should equal 2")

    let tagRecords = Array(Set(ibsRecords.flatMap { $0.tags }))
    XCTAssertEqual(tagRecords.count, 10, "No tag records imported")
  }
}
