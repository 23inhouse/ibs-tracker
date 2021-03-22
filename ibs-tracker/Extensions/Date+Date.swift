//
//  Date+Date.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/3/21.
//

import Foundation

extension Date {
  public func date() -> Date {
    let components = Calendar.current.dateComponents([.year, .month, .day], from: self)
    guard let date = Calendar.current.date(from: components) else {
      fatalError("Failed to strip time from Date object")
    }
    return date
  }
}
