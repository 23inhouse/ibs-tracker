//
//  Pathable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

protocol Pathable {
  func path(in rect: CGRect) -> Path
}
