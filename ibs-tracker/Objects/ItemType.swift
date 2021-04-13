//
//  ItemType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI

enum ItemType: String, CaseIterable {
  case ache
  case bm
  case food
  case gut
  case medication
  case mood
  case note
  case skin
  case weight
  case none

  init(from value: String) {
    if let item = ItemType(rawValue: value) {
      self = item
    } else {
      print("Error: ItemType record type [\(value)] out of range")
      self = .none
    }
  }
}

enum BMColor: String, CaseIterable {
  case none = ""
  case black
  case brown
  case green
  case orange
  case red
  case white
  case yellow

  var color: Color {
    switch self {
    case .none: return .secondary
    case .black: return .black
    case .brown: return Color(UIColor.brown)
    case .green: return .green
    case .orange: return .orange
    case .red: return .red
    case .white: return .white
    case .yellow: return .yellow
    }
  }
}

extension BMColor: OptionalValue {
  var optionalValue: String? {
    self == .none ? nil : rawValue
  }
}

enum BMEvacuation: String, CaseIterable {
  case none = ""
  case partial
  case full

  static let descriptions: [BMEvacuation: String] = [
    .none: "",
    .partial: "partial evacuation",
    .full: "full evacuation",
  ]
}

extension BMEvacuation: OptionalValue {
  var optionalValue: String? {
    self == .none ? nil : rawValue
  }
}

enum BMSmell: String, CaseIterable {
  case none = ""
  case foul
  case sweet

  static let descriptions: [BMSmell: String] = [
    .none: "",
    .foul: "foul smelling",
    .sweet: "sweet smelling",
  ]
}

extension BMSmell: OptionalValue {
  var optionalValue: String? {
    rawValue == "" ? nil : rawValue
  }
}

enum BristolType: Int {
  case b0 = 0
  case b1 = 1
  case b2 = 2
  case b3 = 3
  case b4 = 4
  case b5 = 5
  case b6 = 6
  case b7 = 7

  static let descriptions: [BristolType: String] = [
    .b0: "No Movement Constipation",
    .b1: "Separate hard lumps",
    .b2: "Lumpy & sausage-like",
    .b3: "Sausage shape with cracks",
    .b4: "Perfectly smooth sausage",
    .b5: "Soft blobs with clear-cut edges",
    .b6: "Mushy with ragged edges",
    .b7: "Liquid with no solid pieces"
  ]
}

extension BristolType: Encodable {}
extension BristolType: OptionalValue {
  var optionalValue: Int? {
    self == .b0 ? nil : rawValue
  }
}
extension BristolType: Strideable {
  typealias Stride = Int

  func distance(to other: BristolType) -> Int {
    Stride(other.rawValue) - Stride(self.rawValue)
  }

  func advanced(by n: Int) -> BristolType {
    BristolType(rawValue: numericCast(Stride(self.rawValue) + n))!
  }
}

enum FoodSizes: Int, CaseIterable {
  case none = -1
  case small = 0
  case normal = 1
  case large = 2
  case huge = 3
  case extreme = 4

  static let descriptions: [FoodSizes: String] = [
    .none: "",
    .small: "small portion",
    .normal: "normal portion",
    .large: "large portion",
    .huge: "huge portion",
    .extreme: "extremely large portion",
  ]
}

extension FoodSizes: Sliderable {
  var scaleColor: Color {
    ColorCodedContent.foodSizeColor(for: self, default: .secondary)
  }
}

extension FoodSizes: OptionalValue {
  var optionalValue: Int? {
    self == .none ? nil : rawValue
  }
}

enum MedicationType: String, CaseIterable {
  case analgesic
  case antibiotic
  case anticholinergic
  case antidepressant
  case antidiarrheal = "Anti-diarrheal"
  case antifungal
  case antimicrobial
  case antispasmodic
  case bileacidbinder = "Bile acid binder"
  case digestiveenzyme =  "Digestive enzyme"
  case laxative
  case mastcellstabilizer = "Mast cell stabilizer"
  case probiotic
  case prokinetic
  case protonpumpinhibitor = "Proton pump inhibitor"
  case suppliment
  case vitamin
  case other
  case none

  init?(from value: String?) {
    guard let value = value else {
      return nil
    }

    if let item = MedicationType(rawValue: value) {
      self = item
    } else {
      print("Error: medication record type [\(value)] out of range")
      self = .other
    }
  }
}

extension MedicationType: Encodable {}
extension MedicationType: OptionalValue {
  var optionalValue: String? {
    self == .none ? nil : rawValue
  }
}

enum MoodType: Int {
  case none = -1
  case good = 0
  case soso = 1
  case bad = 2
  case awful = 3
  case extreme = 4

  static let descriptions: [MoodType: String] = [
    .none: "",
    .good: "I feel good",
    .soso: "I feel so-so",
    .bad: "I feel bad",
    .awful: "I feel awful",
    .extreme: "Life sucks",
  ]
}

extension MoodType: Sliderable {
  var scaleColor: Color {
    ColorCodedContent.moodColor(for: self, default: .secondary)
  }
}

extension MoodType: OptionalValue {
  var optionalValue: Int? {
    self == .none ? nil : rawValue
  }
}

enum Scales: Int, CaseIterable {
  case none = -1
  case zero = 0
  case mild = 1
  case moderate = 2
  case severe = 3
  case extreme = 4

  static let validCases = Scales.allCases.filter { $0 != .none }

  static let bloatingDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no bloating at all",
    .mild: "mild feeling of bloating",
    .moderate: "moderate feeling of bloating",
    .severe: "severe feeling of bloating",
    .extreme: "extreme feeling of bloating",
  ]

  static let bodyacheDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no pain at all",
    .mild: "mild pain",
    .moderate: "moderate pain",
    .severe: "severe pain",
    .extreme: "extreme pain",
  ]

  static let drynessDescriptions: [Scales: String] = [
    .none: "",
    .zero: "not dry",
    .mild: "a bit dry",
    .moderate: "moderately dry",
    .severe: "very dry",
    .extreme: "extremely dry",
  ]

  static let foodRiskDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no risk at all",
    .mild: "mildly risky",
    .moderate: "moderatly risky",
    .severe: "I should't eat this",
    .extreme: "I know I can't eat this",
  ]

  static let gutPainDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no tummy pain at all",
    .mild: "mild tummy pain",
    .moderate: "moderate tummy pain",
    .severe: "severe tummy pain",
    .extreme: "extreme tummy pain",
  ]

  static let headacheDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no headache at all",
    .mild: "mild headache",
    .moderate: "moderate headache",
    .severe: "severe headache",
    .extreme: "extreme headache",
  ]

  static let pressureDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no pressure",
    .mild: "mild pressure",
    .moderate: "moderate pressure",
    .severe: "severe pressure",
    .extreme: "extreme pressure",
  ]

  static let skinConditionDescriptions: [Scales: String] = [
    .zero: "no skin condition",
    .mild: "mildly bad condition",
    .moderate: "moderately bad condition",
    .severe: "serverely bad condition",
    .extreme: "extremely bad condition",
  ]

  static let stressDescriptions: [Scales: String] = [
    .none: "",
    .zero: "no stressed at all",
    .mild: "I feel a little stress",
    .moderate: "I feel somewhat stressed",
    .severe: "I feel really stressed",
    .extreme: "I feel extremely stressed",
  ]

  static let wetnessDescriptions: [Scales: String] = [
    .none: "",
    .zero: "not wet",
    .mild: "a bit wet",
    .moderate: "moderately wet",
    .severe: "very wet",
    .extreme: "extremely wet",
  ]

  func label() -> String {
    let labels: [Scales: String] = [
      .none: "none",
      .zero: "none",
      .mild: "mild",
      .moderate: "moderate",
      .severe: "severe",
      .extreme: "extreme",
    ]

    return labels[self]!
  }
}

extension Scales: Sliderable {
  var scaleColor: Color {
    ColorCodedContent.scaleColor(for: self, default: .secondary)
  }
}

extension Scales: OptionalValue {
  var optionalValue: Int? {
    self == .none ? nil : rawValue
  }
}
