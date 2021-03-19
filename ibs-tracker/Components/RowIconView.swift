//
//  RowIconView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct RowIconView: View {
  let type: ItemType
  let color: Color?
  let medicinal: Bool

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  var body: some View {
    medicinalView(medicinal) {
      if [.food, .weight, .medication].contains(type) {
        TypeShape(type: type)
          .stroke(style: strokeStyle)
          .foregroundColor(color)
          .frame(35)
          .padding(10)
      } else {
        TypeShape(type: type)
          .stroke(style: strokeStyle)
          .foregroundColor(color)
          .frame(40)
          .padding(5)
      }
    }
  }

  func medicinalView<Content: View>(_ medicinal: Bool, @ViewBuilder content: @escaping () -> Content) -> some View {
    Group {
      if medicinal {
        ZStack {
          TypeShape(type: .medication)
            .stroke(style: strokeStyle)
            .foregroundColor(color)
            .frame(35)
            .padding(10)
            .offset(CGSize(width: -5, height: -5))
          content()
            .scaleEffect(0.65)
            .offset(CGSize(width: 8, height: 8))
        }
      } else {
        content()
      }
    }
  }
}

struct RowIconView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      RowIconView(type: .food, color: .cgMagenta, medicinal: true)
      RowIconView(type: .note, color: .cgMagenta, medicinal: false)
    }
  }
}
