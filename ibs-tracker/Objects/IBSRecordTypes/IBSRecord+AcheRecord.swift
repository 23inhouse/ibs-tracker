//
//  IBSRecord+AcheRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol AcheRecord: IBSRecordType {
  var headache: Scales? { get }
  var bodyache: Scales? { get }
  init(timestamp: Date, tags: [String], headache: Scales?, bodyache: Scales?)
  func acheScore() -> Scales
  func headacheText() -> String
  func bodyacheText() -> String
}

extension IBSRecord: AcheRecord {
  init(timestamp: Date, tags: [String] = [], headache: Scales?, bodyache: Scales?) {
    self.type = .ache
    self.timestamp = timestamp
    self.headache = headache
    self.bodyache = bodyache
    self.tags = tags
  }

  func acheScore() -> Scales {
    let worstScore = [headache?.rawValue ?? 0, bodyache?.rawValue ?? 0].max()
    return Scales(rawValue: worstScore ?? -1) ?? .zero
  }

  func headacheText() -> String {
    let texts: [Scales: String] = [
      .zero: "no headache at all",
      .mild: "mild headache",
      .moderate: "moderate headache",
      .severe: "severe headache",
      .extreme: "extreme headache",
    ]

    return texts[headache ?? .zero] ?? ""
  }

  func bodyacheText() -> String {
    let texts: [Scales: String] = [
      .zero: "no pain at all",
      .mild: "mild pain",
      .moderate: "moderate pain",
      .severe: "severe pain",
      .extreme: "extreme pain",
    ]

    return texts[bodyache ?? .zero] ?? ""
  }
}
