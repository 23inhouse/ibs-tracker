//
//  MoodShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let PainShapeLayoutConfig = LayoutGuideConfig.grid(columns: 24, rows: 24)

struct MoodShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = PainShapeLayoutConfig.layout(in: rect)

    // lightning top
    p.move(g[15, 4])
    p.line(g[10, 7])
    p.line(g[12, 8])
    p.line(g[9, 11])

    // lightning bottom
    p.line(g[14, 8])
    p.line(g[12, 7])
    p.closeSubpath()

    // head
    p.move(g[17, 24])
    p.curve(g[17, 16], cp1: g[15, 20], cp2: g[16, 18], showControlPoints: showControlPoints)
    p.curve(g[4, 8], cp1: g[25, -1], cp2: g[7, -6], showControlPoints: showControlPoints)
    p.line(g[1, 12])
    p.line(g[4, 12])
    p.line(g[4, 18])
    p.line(g[9, 18])
    p.line(g[10, 24])

    return p
  }
}

extension MoodShape: Pathable {}

struct MoodShapeShape_Previews: PreviewProvider {
  static var previews: some View {
    MoodShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(PainShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
