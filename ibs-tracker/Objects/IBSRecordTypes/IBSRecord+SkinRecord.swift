//
//  IBSRecord+SkinRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 17/3/21.
//

import Foundation

protocol SkinRecord: IBSRecordType {
  var text: String? { get }
  var condition: Scales? { get }
  init(condition: Scales, timestamp: Date, text: String?, tags: [String])
  func skinScore() -> Scales
  func skinText() -> String
}

extension IBSRecord: SkinRecord {
  init(condition: Scales, timestamp: Date, text: String? = nil, tags: [String] = []) {
    self.type = .note
    self.timestamp = timestamp
    self.condition = condition
    self.text = text
    self.tags = tags
  }

  func skinScore() -> Scales {
    return Scales(rawValue: condition?.rawValue ?? 0) ?? .none
  }

  func skinText() -> String {
    guard let skin = condition else { return "" }
    return Scales.skinConditionDescriptions[skin]!
  }
}
