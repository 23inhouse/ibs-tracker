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

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  var body: some View {
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

struct RowIconView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      RowIconView(type: .food, color: .cgMagenta)
      RowIconView(type: .note, color: .cgMagenta)
    }
  }
}
