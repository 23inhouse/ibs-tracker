//
//  Bristol7Shape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let bristol7LayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct Bristol7Shape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = bristol7LayoutConfig.layout(in: rect)

    // bottom
    p.move(g[4, 12])
    p.curve(g[2, 8], cp1: g[3, 12], cp2: g[2, 11], showControlPoints: showControlPoints)
    p.curve(g[4, 0], cp1: g[2, 6], cp2: g[3, 5], showControlPoints: showControlPoints)
    p.curve(g[6, 8], cp1: g[5, 5], cp2: g[6, 6], showControlPoints: showControlPoints)
    p.curve(g[4, 12], cp1: g[6, 11], cp2: g[5, 12], showControlPoints: showControlPoints)

    return p
  }
}

extension Bristol7Shape: Pathable {}

struct Bristol7Shape_Previews: PreviewProvider {
  static var previews: some View {
    Bristol7Shape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(bristol7LayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
