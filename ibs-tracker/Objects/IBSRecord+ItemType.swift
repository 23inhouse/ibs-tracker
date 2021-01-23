//
//  IBSRecord+ItemType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

protocol AcheRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var headache: Int? { get }
  var pain: Int? { get }
  func painScore() -> Int
  func headacheText() -> String
  func painText() -> String
}

extension IBSRecord: AcheRecord {
  func painScore() -> Int {
    [headache ?? 0, pain ?? 0].max() ?? 0
  }

  func headacheText() -> String {
    let texts: [Scales: String] = [
      .none: "no headache at all",
      .mild: "mild headache",
      .moderate: "moderate headache",
      .severe: "severe headache",
      .extreme: "extreme headache",
    ]

    let scaleText = Scales(rawValue: headache ?? 0)
    return texts[scaleText ?? .none] ?? ""
  }

  func painText() -> String {
    let texts: [Scales: String] = [
      .none: "no pain at all",
      .mild: "mild pain",
      .moderate: "moderate pain",
      .severe: "severe pain",
      .extreme: "extreme pain",
    ]

    let scaleText = Scales(rawValue: pain ?? 0)
    return texts[scaleText ?? .none] ?? ""
  }
}

protocol BMRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var bristolType: BristolType? { get }
  func bristolDescription() -> String
}

extension IBSRecord: BMRecord {
  func bristolDescription() -> String {
    guard let bristolScale = bristolScale else { return "" }

    let bristolScaleDescriptions = [
      "No Movement Constipation",
      "Separate hard lumps",
      "Lumpy & sausage-like",
      "Sausage shape with cracks",
      "Perfectly smooth sausage",
      "Soft blobs with clear-cut edges",
      "Mushy with ragged edges",
      "Liquid with no solid pieces"
    ]
    return bristolScaleDescriptions[bristolScale]
  }

  var bristolType: BristolType? {
    BristolType(rawValue: bristolScale ?? 0)
  }
}

protocol FoodRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var text: String? { get }
  var size: String? { get }
  var risk: String? { get }
}

extension IBSRecord: FoodRecord {}

protocol GutRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var bloating: Int? { get }
  var pain: Int? { get }
  func gutScore() -> Int
  func bloatingText() -> String
  func gutPainText() -> String
}

extension IBSRecord: GutRecord {
  func gutScore() -> Int {
    [bloating ?? 0, pain ?? 0].max() ?? 0
  }

  func bloatingText() -> String {
    let texts: [Scales: String] = [
      .none: "no bloating at all",
      .mild: "mild feeling of bloating",
      .moderate: "moderate feeling of bloating",
      .severe: "severe feeling of bloating",
      .extreme: "extreme feeling of bloating",
    ]

    let scaleText = Scales(rawValue: bloating ?? 0)
    return texts[scaleText ?? .none] ?? ""
  }

  func gutPainText() -> String {
    let texts: [Scales: String] = [
      .none: "no tummy pain at all",
      .mild: "mild tummy pain",
      .moderate: "moderate tummy pain",
      .severe: "severe tummy pain",
      .extreme: "extreme tummy pain",
    ]

    let scaleText = Scales(rawValue: pain ?? 0)
    return texts[scaleText ?? .none] ?? ""
  }
}

protocol MedicationRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var text: String? { get }
  var medicationType: MedicationType? { get }
}

extension IBSRecord: MedicationRecord {}

protocol MoodRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var feel: Int? { get }
  var stress: Int? { get }
  func moodScore() -> Int
  func moodText() -> String
  func stressText() -> String
}

extension IBSRecord: MoodRecord {
  func moodScore() -> Int {
    [feel ?? 0, stress ?? 0].max() ?? 0
  }

  func moodText() -> String {
    let texts: [Scales: String] = [
      .none: "I feel very good",
      .mild: "I feel good",
      .moderate: "I feel so so",
      .severe: "I don't feel good",
      .extreme: "I feel awful",
    ]

    let scaleText = Scales(rawValue: feel ?? 0)
    return texts[scaleText ?? .none] ?? ""
  }

  func stressText() -> String {
    let texts: [Scales: String] = [
      .none: "no stressed at all",
      .mild: "I feel a little stress",
      .moderate: "I feel somewhat stressed",
      .severe: "I feel really stressed",
      .extreme: "I feel extremely stressed",
    ]

    let scaleText = Scales(rawValue: stress ?? 0)
    return texts[scaleText ?? .none] ?? ""
  }
}

protocol NoteRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var text: String? { get }
}

extension IBSRecord: NoteRecord {}

protocol WeightRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
  var weight: Double? { get }
}

extension IBSRecord: WeightRecord {}
