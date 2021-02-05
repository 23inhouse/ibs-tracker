//
//  IBSRecord+AcheRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol AcheRecord: IBSRecordType {
  var headache: Int? { get }
  var bodyache: Int? { get }
  init(date: Date, tags: [String], headache: Int?, bodyache: Int?)
  func acheScore() -> Int
  func headacheText() -> String
  func bodyacheText() -> String
}

extension IBSRecord: AcheRecord {
  init(date: Date, tags: [String] = [], headache: Int?, bodyache: Int?) {
    self.type = .ache
    self.timestamp = date.timestampString()
    self.headache = headache
    self.bodyache = bodyache
    self.tags = tags
  }

  func acheScore() -> Int {
    [headache ?? 0, bodyache ?? 0].max() ?? 0
  }

  func headacheText() -> String {
    let texts: [Scales: String] = [
      .zero: "no headache at all",
      .mild: "mild headache",
      .moderate: "moderate headache",
      .severe: "severe headache",
      .extreme: "extreme headache",
    ]

    let scaleText = Scales(rawValue: headache ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func bodyacheText() -> String {
    let texts: [Scales: String] = [
      .zero: "no pain at all",
      .mild: "mild pain",
      .moderate: "moderate pain",
      .severe: "severe pain",
      .extreme: "extreme pain",
    ]

    let scaleText = Scales(rawValue: bodyache ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}
