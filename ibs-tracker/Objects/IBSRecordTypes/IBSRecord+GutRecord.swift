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
  func gutDescription() -> String
  func bloatingText() -> String
  func gutPainText() -> String
}

extension IBSRecord: GutRecord {
  init(timestamp: Date, tags: [String] = [], bloating: Scales?, pain: Scales?) {
    self.type = .gut
    self.timestamp = timestamp
    self.bloating = bloating
    self.pain = pain
    self.tags = tags
  }

  func gutScore() -> Scales {
    let worstScore = [bloating?.rawValue ?? -1, pain?.rawValue ?? -1].max()
    return Scales(optionalValue: worstScore) ?? .none
  }

  func gutDescription() -> String {
    [bloatingText(), gutPainText()].filter { $0 != "" }.joined(separator: " & ")
  }

  func bloatingText() -> String {
    guard let bloating = bloating else { return "" }
    return Scales.bloatingDescriptions[bloating]!
  }

  func gutPainText() -> String {
    guard let pain = pain else { return "" }
    return Scales.gutPainDescriptions[pain]!
  }
}
