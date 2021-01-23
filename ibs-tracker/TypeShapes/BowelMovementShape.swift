//
//  BowelMovementShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let BowelMovementLayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct BowelMovementShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = BowelMovementLayoutConfig.layout(in: rect)

    // bottom layer
    p.move(g[1, 12])
    p.line(g[7, 12])
    p.curve(g[7, 9], cp1: g[9, 12], cp2: g[8, 9], showControlPoints: showControlPoints)
    p.line(g[1, 9])
    p.curve(g[1, 12], cp1: g[0, 9], cp2: g[-1, 12], showControlPoints: showControlPoints)
    p.closeSubpath()

    p.move(g[2, 9])
    p.line(g[6, 9])
    p.curve(g[6, 6], cp1: g[8, 9], cp2: g[7, 6], showControlPoints: showControlPoints)
    p.line(g[2, 6])
    p.curve(g[2, 9], cp1: g[1, 6], cp2: g[0, 9], showControlPoints: showControlPoints)
    p.closeSubpath()

    p.move(g[3, 6])
    p.line(g[5, 6])
    p.curve(g[5, 3], cp1: g[7, 6], cp2: g[6, 3], showControlPoints: showControlPoints)
    p.line(g[3, 3])
    p.curve(g[3, 6], cp1: g[2, 3], cp2: g[1, 6], showControlPoints: showControlPoints)
    p.closeSubpath()

    // top layer
    p.move(g[4, 3])
    p.line(g[4, 3])
    p.curve(g[3, 0], cp1: g[6, 3], cp2: g[4, 0], showControlPoints: showControlPoints)
    p.line(g[3, 0])
    p.curve(g[4, 3], cp1: g[4, 0], cp2: g[2, 3], showControlPoints: showControlPoints)
    p.closeSubpath()

    return p
  }
}

extension BowelMovementShape: Pathable {}

struct BowelMovementShape_Previews: PreviewProvider {
  static var previews: some View {
    BowelMovementShape(showControlPoints: false)
      .stroke(style: strokeStyle)
      .layoutGuide(BowelMovementLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
