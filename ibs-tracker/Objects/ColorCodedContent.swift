//
//  ColorCodedContent.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct ColorCodedContent {
  static func scaleColor(for scale: Scales?, default defaultColor: Color = .primary) -> Color {
    let colors: [Scales: Color] = [
      .zero: .green,
      .mild: .yellow,
      .moderate: .orange,
      .severe: .red,
      .extreme: .purple
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? defaultColor
  }

  static func bristolColor(for scale: BristolType?) -> Color {
    guard let scale = scale else { return .secondary }
    switch scale {
    case .b0: return .red
    case .b1: return .orange
    case .b2: return .yellow
    case .b3: return .green
    case .b4: return .green
    case .b5: return .yellow
    case .b6: return .orange
    case .b7: return .red
    }
  }

  static func foodColor(for record: IBSRecord, default defaultColor: Color = .secondary) -> Color {
    return worstColor([
      foodSizeColor(for: record.size, default: defaultColor),
      scaleColor(for: record.risk, default: defaultColor),
      foodTimeColor(for: record, default: defaultColor)
    ])
  }

  static func foodSizeColor(for scale: FoodSizes?, default defaultColor: Color = .secondary) -> Color {
    let colors: [FoodSizes: Color] = [
      .tiny: .green,
      .small: .green,
      .normal: .yellow,
      .large: .red,
      .huge: .purple
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? defaultColor
  }

  static func foodTimeColor(for record: IBSRecord, default defaultColor: Color = .secondary) -> Color {
    let timestamp = record.timestamp
    let calendar = Calendar.current
    let date = IBSData.currentDate(for: timestamp)
    let hour = calendar.component(.hour, from: date)
    let eightPMAdjusted = 20 - IBSData.numberOfHoursInMorningIncludedInPreviousDay
    let ninePMAdjusted = 21 - IBSData.numberOfHoursInMorningIncludedInPreviousDay
    if hour < eightPMAdjusted {
      return defaultColor
    } else if hour < ninePMAdjusted {
      return .yellow
    } else {
      return .red
    }
  }

  static func moodColor(for scale: MoodType?, default defaultColor: Color = .primary) -> Color {
    let colors: [MoodType: Color] = [
      .great: .green,
      .good: .green,
      .soso: .yellow,
      .bad: .red,
      .awful: .purple,
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? .secondary
  }

  static func worstColor(_ colors: [Color]) -> Color {
    return colors.max { (a, b) in worstColor(a, b) == b } ?? .secondary
  }

  static func worstColor(_ color: Color?, _ other: Color?) -> Color {
    let rankedColors: [Color] = [
      .purple,
      .red,
      .orange,
      .yellow,
      .green
    ]

    for rankedColor in rankedColors {
      if [color, other].contains(rankedColor) {
        return rankedColor
      }
    }

    return .secondary
  }
}
