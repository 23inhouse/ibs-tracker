//
//  IBSRecord+MoodRecord.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 7/2/21.
//

import Foundation

protocol MoodRecord : IBSRecordType {
  var feel: Int? { get }
  var stress: Int? { get }
  init(date: Date, tags: [String], feel: Int?, stress: Int?)
  func moodScore() -> Int
  func feelText() -> String
  func stressText() -> String
}

extension IBSRecord: MoodRecord {
  init(date: Date, tags: [String] = [], feel: Int?, stress: Int?) {
    self.type = .mood
    self.timestamp = date.timestampString()
    self.feel = feel
    self.stress = stress
    self.tags = tags
  }

  func moodScore() -> Int {
    [feel ?? 0, stress ?? 0].max() ?? 0
  }

  func feelText() -> String {
    let texts: [Scales: String] = [
      .zero: "I feel very good",
      .mild: "I feel good",
      .moderate: "I feel so so",
      .severe: "I don't feel good",
      .extreme: "I feel awful",
    ]

    let scaleText = Scales(rawValue: feel ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func stressText() -> String {
    let texts: [Scales: String] = [
      .zero: "no stressed at all",
      .mild: "I feel a little stress",
      .moderate: "I feel somewhat stressed",
      .severe: "I feel really stressed",
      .extreme: "I feel extremely stressed",
    ]

    let scaleText = Scales(rawValue: stress ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}

