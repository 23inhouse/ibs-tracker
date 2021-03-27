//
//  SkinShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 17/3/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let SkinShapeLayoutConfig = LayoutGuideConfig.grid(columns: 24, rows: 24)

struct SkinShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = SkinShapeLayoutConfig.layout(in: rect)

    // outline
    p.move(g[2, 8])
    p.curve(g[1, 9], cp1: g[1, 8], cp2: g[1, 8], showControlPoints: showControlPoints)
    p.curve(g[12, 20], cp1: g[1, 15], cp2: g[6, 20], showControlPoints: showControlPoints)
    p.curve(g[23, 9], cp1: g[18, 20], cp2: g[23, 15], showControlPoints: showControlPoints)
    p.curve(g[22, 8], cp1: g[23, 8], cp2: g[23, 8], showControlPoints: showControlPoints)
    p.line(g[14, 8])
    p.curve(g[12, 15], cp1: g[16, 11], cp2: g[16, 14], showControlPoints: showControlPoints)
    p.curve(g[10, 8], cp1: g[8, 14], cp2: g[8, 11], showControlPoints: showControlPoints)
    p.line(g[9, 8])
    p.closeSubpath()

    p.move(g[1, 11])
    p.line(g[3, 12])
    p.line(g[6, 12])
    p.line(g[9, 11])

    p.move(g[23, 11])
    p.line(g[21, 12])
    p.line(g[18, 12])
    p.line(g[15, 11])

    p.move(g[12, 8])
    p.curve(g[12, 13], cp1: g[14, 11], cp2: g[14, 13], showControlPoints: showControlPoints)
    p.curve(g[12, 8], cp1: g[10, 13], cp2: g[10, 11], showControlPoints: showControlPoints)
    p.closeSubpath()

    p.move(g[12, 8])
    p.curve(g[14, 4], cp1: g[11, 2], cp2: g[14, 4], showControlPoints: showControlPoints)

    return p
  }
}

extension SkinShape: Pathable {}

struct SkinShapeShape_Previews: PreviewProvider {
  static var previews: some View {
    SkinShape(showControlPoints: false)
      .stroke(style: strokeStyle)
      .layoutGuide(SkinShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
