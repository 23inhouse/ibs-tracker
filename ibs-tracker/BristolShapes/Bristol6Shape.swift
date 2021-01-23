//
//  Bristol6Shape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let bristol6LayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct Bristol6Shape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = bristol6LayoutConfig.layout(in: rect)

    // start bottom
    p.move(g[5, 12])
    p.curve(g[7, 10], cp1: g[6, 12], cp2: g[7, 11], showControlPoints: showControlPoints)
    p.curve(g[6, 8], cp1: g[7, 9], cp2: g[7, 8], showControlPoints: showControlPoints)
    p.curve(g[5, 7], cp1: g[5, 8], cp2: g[5, 7], showControlPoints: showControlPoints)
    p.curve(g[6, 6], cp1: g[5, 6], cp2: g[6, 6], showControlPoints: showControlPoints)
    p.curve(g[7, 5], cp1: g[6, 6], cp2: g[7, 6], showControlPoints: showControlPoints)
    p.curve(g[6, 4], cp1: g[7, 4], cp2: g[6, 4], showControlPoints: showControlPoints)
    p.curve(g[3, 1], cp1: g[4, 4], cp2: g[5, 1], showControlPoints: showControlPoints)
    p.curve(g[2, 2], cp1: g[3, 1], cp2: g[2, 1], showControlPoints: showControlPoints)
    p.curve(g[3, 3], cp1: g[2, 3], cp2: g[3, 3], showControlPoints: showControlPoints)
    p.curve(g[4, 5], cp1: g[4, 3], cp2: g[4, 4], showControlPoints: showControlPoints)
    p.curve(g[2, 7], cp1: g[4, 7], cp2: g[2, 7], showControlPoints: showControlPoints)
    p.curve(g[1, 9], cp1: g[1, 7], cp2: g[1, 8], showControlPoints: showControlPoints)
    p.curve(g[3, 11], cp1: g[1, 12], cp2: g[3, 7], showControlPoints: showControlPoints)
    p.curve(g[5, 12], cp1: g[3, 12], cp2: g[4, 12], showControlPoints: showControlPoints)
    p.closeSubpath()

    return p
  }
}

extension Bristol6Shape: Pathable {}

struct Bristol6Shape_Previews: PreviewProvider {
  static var previews: some View {
    Bristol6Shape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(bristol6LayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
