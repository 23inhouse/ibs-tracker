//
//  String+CapitalizeFirstLetter.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 2/3/21.
//

import Foundation

extension String {
  func capitalizeFirstLetter() -> String {
    prefix(1).capitalized + dropFirst()
  }

  mutating func capitalizedFirstLetter() {
    self = self.capitalizeFirstLetter()
  }
}
