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

enum MedicationType: String {
  case antibiotics
  case antimicrobial
  case probiotics
  case prokinetic
  case suppliment
  case other

  init(from value: String?) {
    if let item = MedicationType(rawValue: value ?? "") {
      self = item
    } else {
      print("Error: medication record type [\(String(describing: value))] out of range")
      self = .other
    }
  }
}

enum Scales: Int {
  case zero = 0
  case mild = 1
  case moderate = 2
  case severe = 3
  case extreme = 4
  case none

  init(from value: Int?) {
    if let item = Scales(rawValue: value ?? -1) {
      self = item
    } else {
      print("Error: scale record type out of range")
      self = .none
    }
  }
}

enum MoodType: Int {
  case great = 0
  case good = 1
  case soso = 2
  case bad = 3
  case awful = 4
  case none

  init(from value: Int?) {
    if let item = MoodType(rawValue: value ?? -1) {
      self = item
    } else {
      print("Error: mood record type [\(String(describing: value))] out of range")
      self = .none
    }
  }
}
