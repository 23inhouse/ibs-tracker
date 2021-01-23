//
//  Bristol2Shape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let bristol2LayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct Bristol2Shape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = bristol2LayoutConfig.layout(in: rect)

    p.move(g[2, 6])

    // left bottom
    p.curve(g[3, 8], cp1: g[2, 8], cp2: g[3, 8], showControlPoints: showControlPoints)
    p.curve(g[2, 9], cp1: g[2, 8], cp2: g[2, 9], showControlPoints: showControlPoints)

    // bottom
    p.curve(g[4, 12], cp1: g[2, 11], cp2: g[3, 12], showControlPoints: showControlPoints)
    p.curve(g[6, 9], cp1: g[5, 12], cp2: g[6, 11], showControlPoints: showControlPoints)

    // right bottom
    p.curve(g[5, 8], cp1: g[6, 8], cp2: g[5, 8], showControlPoints: showControlPoints)
    p.curve(g[6, 6], cp1: g[6, 8], cp2: g[6, 6], showControlPoints: showControlPoints)

    // right top
    p.curve(g[5, 4], cp1: g[6, 4], cp2: g[5, 4], showControlPoints: showControlPoints)
    p.curve(g[6, 3], cp1: g[6, 4], cp2: g[6, 3], showControlPoints: showControlPoints)

    // top
    p.curve(g[4, 0], cp1: g[6, 1], cp2: g[5, 0], showControlPoints: showControlPoints)
    p.curve(g[2, 3], cp1: g[3, 0], cp2: g[2, 1], showControlPoints: showControlPoints)

    // left top
    p.curve(g[3, 4], cp1: g[2, 4], cp2: g[3, 4], showControlPoints: showControlPoints)
    p.curve(g[2, 6], cp1: g[2, 4], cp2: g[2, 6], showControlPoints: showControlPoints)

    return p
  }
}

extension Bristol2Shape: Pathable {}

struct Bristol2Shape_Previews: PreviewProvider {
  static var previews: some View {
    Bristol2Shape(showControlPoints: false)
      .stroke(style: strokeStyle)
      .layoutGuide(bristol2LayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
