//
//  Date+String.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/1/21.
//

import Foundation

extension Date {
  static let format = "yyyy-MM-dd HH:mm:ss Z"
  func string(for format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    return formatter.string(from: self)
  }

  func timestampString() -> String {
    self.string(for: Date.format)
  }
}
