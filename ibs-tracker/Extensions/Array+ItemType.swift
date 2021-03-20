//
//  Array+ItemType.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 20/3/21.
//

import Foundation

extension Array where Element == ItemType {
  mutating func remove(element: ItemType) {
    if let index = firstIndex(of: element) {
      remove(at: index)
    }
  }

  mutating func toggle(on: Bool, element: ItemType) {
    on ? append(element) : remove(element: element)
  }
}
