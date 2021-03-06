//
//  PropertyView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 19/1/21.
//

import SwiftUI

struct PropertyView: View {
  let text: String?
  let scale: Int
  let color: Color?
  let direction: LayoutDirection

  init(text: String?, scale: Int, color: Color?, direction: LayoutDirection? = nil) {
    self.text = text
    self.scale = scale
    self.color = color
    self.direction = direction ?? .leftToRight
  }

  init(text: String?, scale: BMEvacuation, color: Color?, direction: LayoutDirection? = nil) {
    self.text = text
    self.scale = scale == .full ? 0 : 1
    self.color = color
    self.direction = direction ?? .leftToRight
  }

  init(text: String?, scale: BMSmell, color: Color?, direction: LayoutDirection? = nil) {
    self.text = text
    self.scale = scale == .sweet ? 1 : 2
    self.color = color
    self.direction = direction ?? .leftToRight
  }

  var body: some View {
    HStack {
      if direction == .leftToRight { icon }
      Text(text ?? "")
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: direction == .leftToRight ? .leading : .trailing)
        .truncationMode(.middle)
        .allowsTightening(true)
        .font(.caption)
        .foregroundColor(.secondary)
      if direction == .rightToLeft { icon }
    }
    .frame(maxWidth: .infinity)
  }

  private var icon: some View {
    Image(systemName: "\(scale).circle")
      .resizedToFit()
      .foregroundColor(color)
      .frame(15)
  }
}

struct PropertyView_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      VStack {
        PropertyView(text: "High", scale: 4, color: .purple, direction: .rightToLeft)
        PropertyView(text: "Good", scale: 2, color: .green, direction: .rightToLeft)
      }
      VStack {
        PropertyView(text: "High", scale: 4, color: .purple, direction: .leftToRight)
        PropertyView(text: "Good", scale: 2, color: .green, direction: .leftToRight)
      }
    }
  }
}
