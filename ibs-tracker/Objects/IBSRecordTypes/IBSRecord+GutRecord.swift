//
//  IBSRecord+GutRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol GutRecord: IBSRecordType {
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
    let worstScore = [bloating?.rawValue ?? -1, pain?.rawValue ?? -1].max()
    return Scales(optionalValue: worstScore) ?? .none
  }

  func bloatingText() -> String {
    return Scales.bloatingDescriptions[bloating ?? .none] ?? ""
  }

  func gutPainText() -> String {
    return Scales.gutPainDescriptions[bodyache ?? .none] ?? ""
  }
}
