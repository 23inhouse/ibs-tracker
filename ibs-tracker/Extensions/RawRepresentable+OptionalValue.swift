//
//  RawRepresentable+OptionalValue.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/2/21.
//

import Foundation

extension RawRepresentable {
  init?(optionalValue: RawValue?) {
    guard let value = optionalValue else { return nil }
    self.init(rawValue: value)
  }
}
