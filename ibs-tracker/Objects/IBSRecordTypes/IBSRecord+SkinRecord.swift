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
  init(timestamp: Date, condition: Scales, text: String?, tags: [String])
  func skinScore() -> Scales
  func skinDescription() -> String
  func skinText() -> String
}

extension IBSRecord: SkinRecord {
  init(timestamp: Date, condition: Scales, text: String? = nil, tags: [String] = []) {
    self.type = .skin
    self.timestamp = timestamp
    self.condition = condition
    self.text = text
    self.tags = tags
  }

  func skinScore() -> Scales {
    return Scales(rawValue: condition?.rawValue ?? 0) ?? .none
  }

  func skinDescription() -> String {
    let preText = text != nil ? "\(text!) is in " : ""
    return "\(preText)\(skinText())"
  }

  func skinText() -> String {
    guard let skin = condition else { return "" }
    return Scales.skinConditionDescriptions[skin]!
  }
}
