//
//  ItemType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import Foundation

enum ItemType: String {
  case ache
  case bm
  case food
  case gut
  case medication
  case mood
  case note
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

extension ItemType: CaseIterable {}

enum BristolType: Int {
  case b0 = 0
  case b1 = 1
  case b2 = 2
  case b3 = 3
  case b4 = 4
  case b5 = 5
  case b6 = 6
  case b7 = 7
}

extension BristolType: Encodable {}

enum MedicationType: String {
  case analgesic
  case antibiotic
  case antimicrobial
  case probiotic
  case prokinetic
  case suppliment
  case vitamin
  case other
  case none

  init(from value: String?) {
    guard value != nil else {
      self = .none
      return
    }

    if let item = MedicationType(rawValue: value ?? "") {
      self = item
    } else {
      print("Error: medication record type [\(String(describing: value))] out of range")
      self = .other
    }
  }
}

enum Scales: Int, CaseIterable {
  case none = -1
  case zero = 0
  case mild = 1
  case moderate = 2
  case severe = 3
  case extreme = 4
}

enum MoodType: Int {
  case none = -1
  case great = 0
  case good = 1
  case soso = 2
  case bad = 3
  case awful = 4
}

enum FoodSizes: Int, CaseIterable {
  case none = -1
  case tiny = 0
  case small = 1
  case normal = 2
  case large = 3
  case huge = 4
}
