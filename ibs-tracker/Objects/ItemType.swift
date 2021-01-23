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
      self = .other
    }
  }
}

enum Scales: Int {
  case none = 0
  case mild = 1
  case moderate = 2
  case severe = 3
  case extreme = 4
}

enum MoodType: Int {
  case great = 0
  case good = 1
  case soso = 2
  case bad = 3
  case awful = 4
}
