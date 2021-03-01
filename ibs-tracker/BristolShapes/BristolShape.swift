//
//  BristolShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)

struct BristolShape: Shape {
  var scale: BristolType

  let bristols: [BristolType: Pathable] = [
    .b1: Bristol1Shape(),
    .b2: Bristol2Shape(),
    .b3: Bristol3Shape(),
    .b4: Bristol4Shape(),
    .b5: Bristol5Shape(),
    .b6: Bristol6Shape(),
    .b7: Bristol7Shape(),
  ]

  func path(in rect: CGRect) -> Path {
    let bristolShape = bristols[scale] ?? Bristol4Shape()
    return bristolShape.path(in: rect)
  }
}

struct BristolShape_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      BristolShape(scale: .b1)
        .stroke(style: strokeStyle)
      BristolShape(scale: .b2)
        .stroke(style: strokeStyle)
      BristolShape(scale: .b3)
        .stroke(style: strokeStyle)
      BristolShape(scale: .b4)
        .stroke(style: strokeStyle)
      BristolShape(scale: .b5)
        .stroke(style: strokeStyle)
      BristolShape(scale: .b6)
        .stroke(style: strokeStyle)
      BristolShape(scale: .b7)
        .stroke(style: strokeStyle)
    }
    .frame(200, 200)
    .previewSizeThatFits()
    .padding(40)
    .showLayoutGuides(true)
  }
}
