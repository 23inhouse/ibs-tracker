//
//  Bristol4Shape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let bristol4LayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct Bristol4Shape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = bristol4LayoutConfig.layout(in: rect)

    p.move(g[2, 6])
    p.line(g[2, 9])
    p.curve(g[4, 12], cp1: g[2, 11], cp2: g[3, 12], showControlPoints: showControlPoints)
    p.curve(g[6, 9], cp1: g[5, 12], cp2: g[6, 11], showControlPoints: showControlPoints)
    p.line(g[6, 3])
    p.curve(g[4, 0], cp1: g[6, 1], cp2: g[5, 0], showControlPoints: showControlPoints)
    p.curve(g[2, 3], cp1: g[3, 0], cp2: g[2, 1], showControlPoints: showControlPoints)

    p.closeSubpath()

    return p
  }
}

extension Bristol4Shape : Pathable {}

struct Bristol4Shape_Previews: PreviewProvider {
  static var previews: some View {
    Bristol4Shape(showControlPoints: false)
      .stroke(style: strokeStyle)
      .layoutGuide(bristol4LayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
