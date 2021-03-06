//
//  IBSRecord+MoodRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol MoodRecord: IBSRecordType {
  var feel: MoodType? { get }
  var stress: Scales? { get }
  init(timestamp: Date, tags: [String], feel: MoodType?, stress: Scales?)
  func moodScore() -> MoodType
  func moodDescription() -> String
  func feelText() -> String
  func stressText() -> String
  func calcMoodMetaTags() -> [String]
}

extension IBSRecord: MoodRecord {
  init(timestamp: Date, tags: [String] = [], feel: MoodType?, stress: Scales?) {
    self.type = .mood
    self.timestamp = timestamp
    self.feel = feel
    self.stress = stress
    self.tags = tags
  }

  func moodScore() -> MoodType {
    let worstScore = [feel?.rawValue ?? -1, stress?.rawValue ?? -1].max()
    return MoodType(optionalValue: worstScore) ?? .none
  }

  func moodDescription() -> String {
    [feelText(), stressText()].filter { $0 != "" }.joined(separator: " & ")
  }

  func feelText() -> String {
    guard let feel = feel else { return "" }
    return MoodType.descriptions[feel]!
  }

  func stressText() -> String {
    guard let stress = stress else { return "" }
    return Scales.stressDescriptions[stress]!
  }

  func calcMoodMetaTags() -> [String] {
    return ["\(type)", "\(moodScore())", moodDescription()] + tags
  }
}
