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

  static func foodColor(for scale: FoodSizes?, default defaultColor: Color = .primary) -> Color {
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
}
