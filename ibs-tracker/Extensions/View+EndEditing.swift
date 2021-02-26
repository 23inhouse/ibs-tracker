//
//  View+EndEditing.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 24/2/21.
//

import SwiftUI

extension View {
  func endEditing(_ force: Bool) {
    UIApplication.shared.windows.forEach { $0.endEditing(force)}
  }
}
