//
//  AcheShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 17/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let PainShapeLayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct AcheShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = PainShapeLayoutConfig.layout(in: rect)

    // top
    p.move(g[7, 1])
    p.line(g[2, 5])
    p.line(g[4, 7])
    p.line(g[1, 11])

    // bottom
    p.line(g[6, 7])
    p.line(g[4, 5])
    p.closeSubpath()

    return p
  }
}

extension AcheShape: Pathable {}

struct AcheShapeShape_Previews: PreviewProvider {
  static var previews: some View {
    AcheShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(PainShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
