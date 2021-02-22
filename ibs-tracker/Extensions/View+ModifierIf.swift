//
//  View+ModifierIf.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 21/2/21.
//

import SwiftUI

extension View {
  func modifierIf<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
    if conditional {
      return AnyView(content(self))
    } else {
      return AnyView(self)
    }
  }
}
