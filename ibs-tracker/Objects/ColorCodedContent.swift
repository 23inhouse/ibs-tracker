//
//  ColorCodedContent.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct ColorCodedContent {
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

  static func scaleColor(for scale: Int?) -> Color {
    let colors: [Scales: Color] = [
      .none: .green,
      .mild: .yellow,
      .moderate: .orange,
      .severe: .red,
      .extreme: .purple
    ]

    guard let scale = scale else { return .primary }
    let color = Scales(rawValue: scale)
    return colors[color ?? .none] ?? .primary
  }

  static func bristolColor(for scale: Int) -> Color {
    let colors: [BristolType: Color] = [
      .b0: .red,
      .b1: .orange,
      .b2: .yellow,
      .b3: .green,
      .b4: .green,
      .b5: .yellow,
      .b6: .orange,
      .b7: .red,
    ]

    let color = BristolType(rawValue: scale)
    return colors[color ?? .b1] ?? .secondary
  }

  static func moodColor(for scale: Int?) -> Color {
    let colors: [MoodType: Color] = [
      .great: .green,
      .good: .green,
      .soso: .yellow,
      .bad: .red,
      .awful: .purple,
    ]

    guard let scale = scale else { return .secondary }
    let color = MoodType(rawValue: scale)
    return colors[color ?? .soso] ?? .secondary
  }
}
