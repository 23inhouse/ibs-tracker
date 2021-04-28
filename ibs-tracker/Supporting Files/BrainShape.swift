//
//  BrainShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 28/4/21.
//

import Foundation
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)
private let GutShapeLayoutConfig = LayoutGuideConfig.grid(columns: 24, rows: 24)

struct BrainShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = GutShapeLayoutConfig.layout(in: rect)

    let diameter = rect.width * 1.35

//    let showControlPoints = false

    // left arc
    p.move(g[10, 24])
    p.addArc(center: g[12, 12], radius: diameter / 2, startAngle: Angle(degrees: 94), endAngle: Angle(degrees: -100), clockwise: false)
    p.line(g[10, 0])

    // left 1
    p.curve(g[4, 6], cp1: g[11, 5], cp2: g[7, 6], showControlPoints: showControlPoints)
    p.curve(g[0, 10], cp1: g[2, 6], cp2: g[0, 7], showControlPoints: showControlPoints)
    p.curve(g[18, 14], cp1: g[0, 16], cp2: g[4, 16], showControlPoints: showControlPoints)

    p.curve(g[10, 24], cp1: g[10, 15], cp2: g[8, 18], showControlPoints: showControlPoints)

    p.closeSubpath()


    return p
  }
}

extension BrainShape: Pathable {}

struct BrainShape_Previews: PreviewProvider {
  static var previews: some View {
    List {
      BrainShape(showControlPoints: true)
        .stroke(style: strokeStyle)
        .layoutGuide(GutShapeLayoutConfig)
        .frame(200, 200)
        .previewSizeThatFits()
        .padding(40)
        .showLayoutGuides(true)
      AppIconView()
    }
  }
}
