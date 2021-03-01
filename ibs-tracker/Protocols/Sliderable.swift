//
//  Sliderable.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 2/3/21.
//

import SwiftUI

protocol Sliderable: RawRepresentable, Hashable where RawValue == Int {
  var scaleColor: Color { get }
}
