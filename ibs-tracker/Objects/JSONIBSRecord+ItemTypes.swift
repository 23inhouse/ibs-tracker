//
//  IBSRecord+ItemType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

protocol IBSRecord {
  func dateString(for format: String) -> String
  var tags: [String] { get }
}

protocol AcheRecord: IBSRecord {
  var headache: Int? { get }
  var pain: Int? { get }
  func painScore() -> Int
  func headacheText() -> String
  func painText() -> String
}

extension JSONIBSRecord: AcheRecord {
  func painScore() -> Int {
    [headache ?? 0, pain ?? 0].max() ?? 0
  }

  func headacheText() -> String {
    let texts: [Scales: String] = [
      .zero: "no headache at all",
      .mild: "mild headache",
      .moderate: "moderate headache",
      .severe: "severe headache",
      .extreme: "extreme headache",
    ]

    let scaleText = Scales(rawValue: headache ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func painText() -> String {
    let texts: [Scales: String] = [
      .zero: "no pain at all",
      .mild: "mild pain",
      .moderate: "moderate pain",
      .severe: "severe pain",
      .extreme: "extreme pain",
    ]

    let scaleText = Scales(rawValue: pain ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}

protocol BMRecord : IBSRecord {
  var bristolType: BristolType? { get }
  func bristolDescription() -> String
}

extension JSONIBSRecord: BMRecord {
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

protocol FoodRecord : IBSRecord {
  var text: String? { get }
  var size: Int? { get }
  var risk: Int? { get }
  func FoodScore() -> Int
  func riskText() -> String
  func sizeText() -> String
}

extension JSONIBSRecord: FoodRecord {
  func FoodScore() -> Int {
    [risk ?? 0, size ?? 0].max() ?? 0
  }

  func riskText() -> String {
    let texts: [Scales: String] = [
      .zero: "no risk at all",
      .mild: "mildly risky",
      .moderate: "moderatly risky",
      .severe: "I should't eat this",
      .extreme: "I know I can't eat this",
    ]

    let scaleText = Scales(rawValue: risk ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func sizeText() -> String {
    let texts: [Scales: String] = [
      .zero: "Very small meal",
      .mild: "Small meal",
      .moderate: "Normal meal size",
      .severe: "A bit too much",
      .extreme: "Way to much",
    ]

    let scaleText = Scales(rawValue: size ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}

protocol GutRecord : IBSRecord {
  var bloating: Int? { get }
  var pain: Int? { get }
  func gutScore() -> Int
  func bloatingText() -> String
  func gutPainText() -> String
}

extension JSONIBSRecord: GutRecord {
  func gutScore() -> Int {
    [bloating ?? 0, pain ?? 0].max() ?? 0
  }

  func bloatingText() -> String {
    let texts: [Scales: String] = [
      .zero: "no bloating at all",
      .mild: "mild feeling of bloating",
      .moderate: "moderate feeling of bloating",
      .severe: "severe feeling of bloating",
      .extreme: "extreme feeling of bloating",
    ]

    let scaleText = Scales(rawValue: bloating ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }

  func gutPainText() -> String {
    let texts: [Scales: String] = [
      .zero: "no tummy pain at all",
      .mild: "mild tummy pain",
      .moderate: "moderate tummy pain",
      .severe: "severe tummy pain",
      .extreme: "extreme tummy pain",
    ]

    let scaleText = Scales(rawValue: pain ?? 0)
    return texts[scaleText ?? .zero] ?? ""
  }
}

protocol MedicationRecord : IBSRecord {
  var text: String? { get }
  var medicationType: MedicationType? { get }
}

extension JSONIBSRecord: MedicationRecord {}

protocol MoodRecord : IBSRecord {
  var feel: Int? { get }
  var stress: Int? { get }
  func moodScore() -> Int
  func feelText() -> String
  func stressText() -> String
}

extension JSONIBSRecord: MoodRecord {
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

protocol NoteRecord : IBSRecord {
  var text: String? { get }
}

extension JSONIBSRecord: NoteRecord {}

protocol WeightRecord : IBSRecord {
  var weight: Double? { get }
}

extension JSONIBSRecord: WeightRecord {}
