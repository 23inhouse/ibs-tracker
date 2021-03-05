//
//  Array+MedicationType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 8/3/21.
//

import Foundation

extension Array where Element == MedicationType {
  mutating func remove(element: MedicationType) {
    if let index = firstIndex(of: element) {
      remove(at: index)
    }
  }

  mutating func toggle(on: Bool, element: MedicationType) {
    on ? append(element) : remove(element: element)
  }
}
