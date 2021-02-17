//
//  String+UrlTests.swift
//  ibs-trackerTests
//
//  Created by Benjamin Lewis on 12/2/21.
//

import XCTest
@testable import ibs_tracker

class String_UrlTests: XCTestCase {
  func testUrl() throws {
    let bundle = Bundle(for: type(of: self))

    let dataSet = try bundle.decode(DataSet.self, from: "records-to-import.json")
    let jsonString = DataSet.encode(dataSet)
    let url = jsonString?.url(path: "export.json")

    let resources = try url?.resourceValues(forKeys:[.fileSizeKey])
    let fileSize = resources?.fileSize

    XCTAssertEqual(fileSize, 2046, "json file contents should be 2046bytes")
  }
}
