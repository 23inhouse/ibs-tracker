//
//  Binding+Dismiss.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/3/21.
//

import SwiftUI

extension Binding where Value == PresentationMode {
  func dismiss(animation animationType: Animation? = .default) {
    if animationType == .none {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        animation(animationType).wrappedValue.dismiss()
      }
    } else {
      DispatchQueue.main.async {
        animation(animationType).wrappedValue.dismiss()
      }
    }
  }
}
