//
//  WeightShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let WeightShapeLayoutConfig = LayoutGuideConfig.grid(columns: 12, rows: 12)

struct WeightShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = WeightShapeLayoutConfig.layout(in: rect)


    // display
    p.move(g[3, 6])
    p.line(g[2, 4])
    p.curve(g[10, 4], cp1: g[4, 2], cp2: g[8, 2], showControlPoints: showControlPoints)
    p.line(g[9, 6])
    p.curve(g[3, 6], cp1: g[7, 5], cp2: g[5, 5], showControlPoints: showControlPoints)
    p.closeSubpath()

    // outline
    p.move(g[6, 1])
    p.line(g[3, 1])
    p.curve(g[1, 3], cp1: g[2, 1], cp2: g[1, 2], showControlPoints: showControlPoints)
    p.line(g[1, 6])
    p.line(g[1, 9])
    p.curve(g[3, 11], cp1: g[1, 10], cp2: g[2, 11], showControlPoints: showControlPoints)
    p.line(g[9, 11])
    p.curve(g[11, 9], cp1: g[10, 11], cp2: g[11, 10], showControlPoints: showControlPoints)
    p.line(g[11, 3])
    p.curve(g[9, 1], cp1: g[11, 2], cp2: g[10, 1], showControlPoints: showControlPoints)
    p.line(g[6, 1])
//    p.line(g[3, 1])
//    p.curve(g[1, 3], cp1: g[2, 1], cp2: g[1, 1], showControlPoints: showControlPoints)
//    p.line(g[1, 6])
    p.closeSubpath()

    // dail
    p.move(g[6, 5])
    p.line(g[6, 4])


    return p
  }
}

extension WeightShape: Pathable {}

struct WeightShapeShape_Previews: PreviewProvider {
  static var previews: some View {
    WeightShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(WeightShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
