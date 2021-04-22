//
//  ColorCodedContent.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct ColorCodedContent {
  static let rankedColors: [Color] = [
    .purple,
    .red,
    .orange,
    .yellow,
    .green
  ]

  static func color(for record: IBSRecord) -> Color {
    switch record.type {
    case .ache:
      return worstColor([record.bodyache, record.headache])
    case .bm:
      return bristolColor(for: record.bristolScale)
    case .food:
      return foodColor(for: record, default: .green)
    case .gut:
      return worstColor([record.bloating, record.pain])
    case .mood:
      return worstColor(moodColor(for: record.feel), scaleColor(for: record.stress))
    case .skin:
      return skinConditionColor(for: record.condition)
    default:
      return .secondary
    }
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

  static func scaleColor(for scale: BMEvacuation?, default defaultColor: Color = .primary) -> Color {
    let colors: [BMEvacuation: Color] = [
      .full: .green,
      .partial: .yellow,
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? defaultColor
  }

  static func scaleColor(for scale: BMSmell?, default defaultColor: Color = .primary) -> Color {
    let colors: [BMSmell: Color] = [
      .sweet: .yellow,
      .foul: .orange,
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? defaultColor
  }

  static func bristolColor(for scale: BristolType?, default defaultColor: Color = .primary) -> Color {
    guard let scale = scale else { return defaultColor }
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
    guard record.medicinal != true else { return .secondary }
    return worstColor([
      foodSizeColor(for: record.size, default: defaultColor),
      scaleColor(for: record.speed, default: defaultColor),
      scaleColor(for: record.risk, default: defaultColor),
      scaleColor(for: record.mealTooLate, default: defaultColor),
      scaleColor(for: record.mealTooLong, default: defaultColor),
      scaleColor(for: record.mealTooSoon, default: defaultColor),
    ])
  }

  static func foodSizeColor(for scale: FoodSizes?, default defaultColor: Color = .secondary) -> Color {
    let colors: [FoodSizes: Color] = [
      .small: .green,
      .normal: .yellow,
      .large: .orange,
      .huge: .red,
      .extreme: .purple
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? defaultColor
  }

  static func moodColor(for scale: MoodType?, default defaultColor: Color = .primary) -> Color {
    let colors: [MoodType: Color] = [
      .good: .green,
      .soso: .yellow,
      .bad: .orange,
      .awful: .red,
      .extreme: .purple,
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? .secondary
  }

  static func skinConditionColor(for scale: Scales?, default defaultColor: Color = .primary) -> Color {
    let colors: [Scales: Color] = [
      .zero: .green,
      .mild: .yellow,
      .moderate: .orange,
      .severe: .red,
      .extreme: .purple
    ]

    guard let scale = scale else { return defaultColor }
    return colors[scale] ?? .secondary
  }

  static func worstColor(_ scales: [Scales?]) -> Color {
    let colers = scales.map { scaleColor(for: $0) }.compactMap { $0 }
    return worstColor(colers)
  }

  static func worstColor(_ colors: [Color]) -> Color {
    return colors.max { (a, b) in worstColor(a, b) == b } ?? .secondary
  }

  static func worstColor(_ color: Color?, _ other: Color?) -> Color {
    for rankedColor in rankedColors {
      if [color, other].contains(rankedColor) {
        return rankedColor
      }
    }

    return .secondary
  }
}
