//
//  RawRepresentable+OptionalValue.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/2/21.
//

import Foundation

protocol OptionalValue {
  associatedtype RawValue

  var optionalValue: RawValue? { get }
  init?(optionalValue: RawValue?)
}

extension RawRepresentable where Self: OptionalValue {
  init?(optionalValue: RawValue?) {
    guard let value = optionalValue else { return nil }
    self.init(rawValue: value)
  }
}
