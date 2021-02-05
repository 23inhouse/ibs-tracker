//
//  IBSRecord+GutRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol GutRecord : IBSRecordType {
  var bloating: Int? { get }
  var pain: Int? { get }
  init(date: Date, tags: [String], bloating: Int?, pain: Int?)
  func gutScore() -> Int
  func bloatingText() -> String
  func gutPainText() -> String
}

extension IBSRecord: GutRecord {
  init(date: Date, tags: [String] = [], bloating: Int?, pain: Int?) {
    self.type = .gut
    self.timestamp = date.timestampString()
    self.bloating = bloating
    self.bodyache = pain
    self.tags = tags
  }

  func gutScore() -> Int {
    [bloating ?? 0, bodyache ?? 0].max() ?? 0
  }

  func bloatingText() -> String {
    let texts: [Scales: String] = [
      .zero: "no bloating at all",
      .mild: "mild feeling of bloating",
      .moderate: "moderate feeling of bloating",
      .severe: "severe feeling of bloating",
      .extreme: "extreme feeling of bloating",
    ]

    let scaleText = Scales(rawValue: bloating ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func gutPainText() -> String {
    let texts: [Scales: String] = [
      .zero: "no tummy pain at all",
      .mild: "mild tummy pain",
      .moderate: "moderate tummy pain",
      .severe: "severe tummy pain",
      .extreme: "extreme tummy pain",
    ]

    let scaleText = Scales(rawValue: bodyache ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}
