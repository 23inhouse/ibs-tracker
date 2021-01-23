//
//  GutShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let GutShapeLayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct GutShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = GutShapeLayoutConfig.layout(in: rect)

    // left 1
    p.move(g[3, 0])
    p.curve(g[2, 2], cp1: g[3, 1], cp2: g[3, 2], showControlPoints: showControlPoints)
    p.curve(g[0, 4], cp1: g[1, 2], cp2: g[0, 2], showControlPoints: showControlPoints)
    p.curve(g[2, 6], cp1: g[0, 6], cp2: g[1, 6], showControlPoints: showControlPoints)

    // left 2
    p.line(g[6, 6])
    p.move(g[2, 6])
    p.curve(g[1, 8], cp1: g[2, 6], cp2: g[1, 6], showControlPoints: showControlPoints)
    p.curve(g[2, 10], cp1: g[1, 10], cp2: g[2, 10], showControlPoints: showControlPoints)

    // left 3
    p.curve(g[4, 12], cp1: g[3, 10], cp2: g[4, 10], showControlPoints: showControlPoints)

    // right 1
    p.move(g[5, 0])
    p.curve(g[3, 4], cp1: g[5, 1], cp2: g[5, 4], showControlPoints: showControlPoints)
    p.line(g[2, 4])

    // right 2
    p.move(g[3, 4])
    p.line(g[6, 4])
    p.curve(g[8, 6], cp1: g[7, 4], cp2: g[8, 4], showControlPoints: showControlPoints)
    p.curve(g[6, 8], cp1: g[8, 8], cp2: g[7, 8], showControlPoints: showControlPoints)
    p.line(g[3, 8])

    // right 3
    p.move(g[3, 8])
    p.curve(g[6, 12], cp1: g[6, 8], cp2: g[6, 9], showControlPoints: showControlPoints)

    //    // left 1
//    p.move(g[3, 0])
//    p.curve(g[2, 2], cp1: g[3, 1], cp2: g[3, 2], showControlPoints: showControlPoints)
//    p.curve(g[0, 4], cp1: g[1, 2], cp2: g[0, 2], showControlPoints: showControlPoints)
//    p.curve(g[2, 6], cp1: g[0, 6], cp2: g[1, 6], showControlPoints: showControlPoints)
//
//    // left 2
//    p.line(g[6, 6])
//    p.move(g[2, 6])
//    p.curve(g[0, 8], cp1: g[1, 6], cp2: g[0, 6], showControlPoints: showControlPoints)
//    p.curve(g[1, 10], cp1: g[0, 10], cp2: g[1, 10], showControlPoints: showControlPoints)
//
//    // left 3
//    p.curve(g[3, 12], cp1: g[2, 10], cp2: g[3, 10], showControlPoints: showControlPoints)
//
//    // right 1
//    p.move(g[5, 0])
//    p.curve(g[3, 4], cp1: g[5, 1], cp2: g[5, 4], showControlPoints: showControlPoints)
//    p.line(g[2, 4])
//
//    // right 2
//    p.move(g[3, 4])
//    p.line(g[6, 4])
//    p.curve(g[8, 6], cp1: g[7, 4], cp2: g[8, 4], showControlPoints: showControlPoints)
//    p.curve(g[6, 8], cp1: g[8, 8], cp2: g[7, 8], showControlPoints: showControlPoints)
//    p.line(g[2, 8])
//
//    // right 3
//    p.move(g[2, 8])
//    p.curve(g[5, 12], cp1: g[5, 8], cp2: g[5, 9], showControlPoints: showControlPoints)

//    // left 1
//    p.move(g[3, 0])
//    p.line(g[3, 1])
//    p.curve(g[2, 2], cp1: g[3, 2], cp2: g[3, 2], showControlPoints: showControlPoints)
//    p.curve(g[1, 3], cp1: g[1, 2], cp2: g[1, 2], showControlPoints: showControlPoints)
//    p.curve(g[2, 4], cp1: g[1, 4], cp2: g[1, 4], showControlPoints: showControlPoints)
//
//    // left 2
//    p.line(g[6, 4])
//    p.move(g[2, 4])
//    p.curve(g[1, 5], cp1: g[1, 4], cp2: g[1, 4], showControlPoints: showControlPoints)
//    p.curve(g[2, 6], cp1: g[1, 6], cp2: g[1, 6], showControlPoints: showControlPoints)
//
//    // left 3
//    p.line(g[6, 6])
//    p.move(g[2, 6])
//    p.curve(g[1, 7], cp1: g[1, 6], cp2: g[1, 6], showControlPoints: showControlPoints)
//    p.curve(g[2, 8], cp1: g[1, 8], cp2: g[1, 8], showControlPoints: showControlPoints)
//
//    // left 4
//    p.line(g[6, 8])
//    p.move(g[2, 8])
//    p.curve(g[1, 9], cp1: g[1, 8], cp2: g[1, 8], showControlPoints: showControlPoints)
//    p.curve(g[2, 10], cp1: g[1, 10], cp2: g[1, 10], showControlPoints: showControlPoints)
//
//    // left 5
//    p.line(g[3, 10])
//    p.curve(g[4, 11], cp1: g[4, 10], cp2: g[4, 10], showControlPoints: showControlPoints)
//    p.line(g[4, 12])
//
//    // right 1
//    p.move(g[4, 0])
//    p.line(g[4, 1])
//    p.curve(g[2, 3], cp1: g[4, 3], cp2: g[4, 3], showControlPoints: showControlPoints)
//    p.line(g[2, 3])
//
//    // right 2
//    p.move(g[3, 3])
//    p.line(g[6, 3])
//    p.curve(g[7, 4], cp1: g[7, 3], cp2: g[7, 3], showControlPoints: showControlPoints)
//    p.curve(g[6, 5], cp1: g[7, 5], cp2: g[7, 5], showControlPoints: showControlPoints)
//    p.line(g[2, 5])
//
//    // right 3
//    p.move(g[6, 5])
//    p.curve(g[7, 6], cp1: g[7, 5], cp2: g[7, 5], showControlPoints: showControlPoints)
//    p.curve(g[6, 7], cp1: g[7, 7], cp2: g[7, 7], showControlPoints: showControlPoints)
//    p.line(g[2, 7])
//
//    // right 4
//    p.move(g[6, 7])
//    p.curve(g[7, 8], cp1: g[7, 7], cp2: g[7, 7], showControlPoints: showControlPoints)
//    p.curve(g[6, 9], cp1: g[7, 9], cp2: g[7, 9], showControlPoints: showControlPoints)
//    p.line(g[2, 9])
//
//    // right 5
//    p.move(g[4, 9])
//    p.curve(g[5, 10], cp1: g[5, 9], cp2: g[5, 9], showControlPoints: showControlPoints)
//    p.line(g[5, 12])

    return p
  }
}

extension GutShape: Pathable {}

struct GutShape_Previews: PreviewProvider {
  static var previews: some View {
    GutShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(GutShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
