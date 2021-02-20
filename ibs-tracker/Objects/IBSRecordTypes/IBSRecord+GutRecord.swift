//
//  IBSRecord+GutRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol GutRecord : IBSRecordType {
  var bloating: Scales? { get }
  var pain: Scales? { get }
  init(timestamp: Date, tags: [String], bloating: Scales?, pain: Scales?)
  func gutScore() -> Scales
  func bloatingText() -> String
  func gutPainText() -> String
}

extension IBSRecord: GutRecord {
  init(timestamp: Date, tags: [String] = [], bloating: Scales?, pain: Scales?) {
    self.type = .gut
    self.timestamp = timestamp
    self.bloating = bloating
    self.bodyache = pain
    self.tags = tags
  }

  func gutScore() -> Scales {
    let worstScore = [bloating?.rawValue ?? 0, bodyache?.rawValue ?? 0].max() ?? -1
    return Scales(rawValue: worstScore) ?? .zero
  }

  func bloatingText() -> String {
    let texts: [Scales: String] = [
      .zero: "no bloating at all",
      .mild: "mild feeling of bloating",
      .moderate: "moderate feeling of bloating",
      .severe: "severe feeling of bloating",
      .extreme: "extreme feeling of bloating",
    ]

    return texts[bloating ?? .zero] ?? ""
  }

  func gutPainText() -> String {
    let texts: [Scales: String] = [
      .zero: "no tummy pain at all",
      .mild: "mild tummy pain",
      .moderate: "moderate tummy pain",
      .severe: "severe tummy pain",
      .extreme: "extreme tummy pain",
    ]

    return texts[bodyache ?? .zero] ?? ""
  }
}
