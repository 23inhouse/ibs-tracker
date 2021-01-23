//
//  MedicationShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let MedicationShapeLayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 8)

struct MedicationShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = MedicationShapeLayoutConfig.layout(in: rect)

    // outline
    p.move(g[3, 3])
    p.line(g[5, 1])
    p.curve(g[7, 1], cp1: g[6, 0], cp2: g[7, 1], showControlPoints: showControlPoints)
    p.curve(g[7, 3], cp1: g[8, 2], cp2: g[7, 3], showControlPoints: showControlPoints)
    p.line(g[5, 5])
    p.closeSubpath()

    p.move(g[3, 3])
    p.line(g[1, 5])
    p.curve(g[1, 7], cp1: g[0, 6], cp2: g[1, 7], showControlPoints: showControlPoints)
    p.curve(g[3, 7], cp1: g[2, 8], cp2: g[3, 7], showControlPoints: showControlPoints)
    p.line(g[5, 5])
    p.closeSubpath()

    p.move(g[3, 4])
    p.line(g[1, 6])

    return p
  }
}

extension MedicationShape: Pathable {}

struct MedicationShapeShape_Previews: PreviewProvider {
  static var previews: some View {
    MedicationShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(MedicationShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
