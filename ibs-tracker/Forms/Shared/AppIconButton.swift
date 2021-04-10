//
//  AppIconButton.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/4/21.
//

import SwiftUI

struct AppIconButton: View {
  var angle: Angle
  var scale: CGFloat = 1.0

  var body: some View {
    AppIconView(size: 150 * scale)
      .contentShape(Rectangle())
      .rotate(angle)
      .foregroundColor(.secondary)
  }
}
