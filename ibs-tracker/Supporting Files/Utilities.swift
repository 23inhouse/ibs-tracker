//
//  Utilities.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import Foundation

struct Utilities {
  static func measure(_ block: () -> Void) {
    let start = DispatchTime.now()
    block()
    let end = DispatchTime.now()

    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = round(Double(nanoTime) / 1_000_000) / 1_000
    print("Executed in: \(timeInterval) seconds")
  }
}
