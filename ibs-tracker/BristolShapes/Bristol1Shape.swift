//
//  Bristol1Shape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let bristol1LayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct Bristol1Shape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = bristol1LayoutConfig.layout(in: rect)

    // top
    p.move(g[3, 0])
    p.curve(g[2, 1], cp1: g[3, 0], cp2: g[2, 0], showControlPoints: showControlPoints)
    p.curve(g[3, 4], cp1: g[2, 2], cp2: g[2, 4], showControlPoints: showControlPoints)
    p.curve(g[4, 1], cp1: g[4, 4], cp2: g[4, 2], showControlPoints: showControlPoints)
    p.curve(g[3, 0], cp1: g[4, 0], cp2: g[3, 0], showControlPoints: showControlPoints)

    // bottom
    p.move(g[5, 12])
    p.curve(g[4, 11], cp1: g[5, 12], cp2: g[4, 12], showControlPoints: showControlPoints)
    p.curve(g[5, 8], cp1: g[4, 10], cp2: g[4, 8], showControlPoints: showControlPoints)
    p.curve(g[6, 11], cp1: g[6, 8], cp2: g[6, 10], showControlPoints: showControlPoints)
    p.curve(g[5, 12], cp1: g[6, 12], cp2: g[5, 12], showControlPoints: showControlPoints)

    // left
    p.move(g[2, 5])
    p.curve(g[1, 6], cp1: g[2, 5], cp2: g[1, 5], showControlPoints: showControlPoints)
    p.curve(g[2, 9], cp1: g[1, 7], cp2: g[1, 9], showControlPoints: showControlPoints)
    p.curve(g[3, 6], cp1: g[3, 9], cp2: g[3, 7], showControlPoints: showControlPoints)
    p.curve(g[2, 5], cp1: g[3, 5], cp2: g[2, 5], showControlPoints: showControlPoints)

    // right
    p.move(g[6, 7])
    p.curve(g[5, 6], cp1: g[6, 7], cp2: g[5, 7], showControlPoints: showControlPoints)
    p.curve(g[6, 3], cp1: g[5, 5], cp2: g[5, 3], showControlPoints: showControlPoints)
    p.curve(g[7, 6], cp1: g[7, 3], cp2: g[7, 5], showControlPoints: showControlPoints)
    p.curve(g[6, 7], cp1: g[7, 7], cp2: g[6, 7], showControlPoints: showControlPoints)

    // center
    p.move(g[4, 4])
    p.curve(g[3, 6], cp1: g[3, 4], cp2: g[3, 5], showControlPoints: showControlPoints)
    p.curve(g[4, 8], cp1: g[3, 7], cp2: g[3, 8], showControlPoints: showControlPoints)
    p.curve(g[5, 6], cp1: g[5, 8], cp2: g[5, 7], showControlPoints: showControlPoints)
    p.curve(g[4, 4], cp1: g[5, 5], cp2: g[5, 4], showControlPoints: showControlPoints)

    return p
  }
}

extension Bristol1Shape: Pathable {}

struct Bristol1Shape_Previews: PreviewProvider {
  static var previews: some View {
    Bristol1Shape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(bristol1LayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
