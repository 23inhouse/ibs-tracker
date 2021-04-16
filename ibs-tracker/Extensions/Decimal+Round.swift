//
//  Decimal+Round.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/4/21.
//

import Foundation

extension Decimal {
  mutating func round(_ roundingMode: NSDecimalNumber.RoundingMode = .plain, _ scale: Int = 0) {
    var localCopy = self
    NSDecimalRound(&self, &localCopy, scale, roundingMode)
  }

  func rounded( _ roundingMode: NSDecimalNumber.RoundingMode = .plain, _ scale: Int = 0) -> Decimal {
    var result = Decimal()
    var localCopy = self
    NSDecimalRound(&result, &localCopy, scale, roundingMode)
    return result
  }
}
