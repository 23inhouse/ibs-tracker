//
//  Bristol5Shape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let bristol5LayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct Bristol5Shape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = bristol5LayoutConfig.layout(in: rect)

    // top
    p.move(g[4, 0])
    p.curve(g[3, 1], cp1: g[4, 0], cp2: g[3, 0], showControlPoints: showControlPoints)
    p.curve(g[4, 4], cp1: g[3, 2], cp2: g[3, 3], showControlPoints: showControlPoints)
    p.curve(g[5, 1], cp1: g[5, 3], cp2: g[5, 2], showControlPoints: showControlPoints)
    p.curve(g[4, 0], cp1: g[5, 0], cp2: g[4, 0], showControlPoints: showControlPoints)

    // bottom
    p.move(g[4, 12])
    p.curve(g[3, 11], cp1: g[4, 12], cp2: g[3, 12], showControlPoints: showControlPoints)
    p.curve(g[4, 8], cp1: g[3, 10], cp2: g[3, 9], showControlPoints: showControlPoints)
    p.curve(g[5, 11], cp1: g[5, 9], cp2: g[5, 10], showControlPoints: showControlPoints)
    p.curve(g[4, 12], cp1: g[5, 12], cp2: g[4, 12], showControlPoints: showControlPoints)

    // left
    p.move(g[3, 8])
    p.curve(g[2, 7], cp1: g[3, 8], cp2: g[2, 8], showControlPoints: showControlPoints)
    p.curve(g[3, 4], cp1: g[2, 6], cp2: g[2, 5], showControlPoints: showControlPoints)
    p.curve(g[4, 7], cp1: g[4, 5], cp2: g[4, 6], showControlPoints: showControlPoints)
    p.curve(g[3, 8], cp1: g[4, 8], cp2: g[3, 8], showControlPoints: showControlPoints)

    // right
    p.move(g[5, 7])
    p.curve(g[4, 6], cp1: g[5, 7], cp2: g[4, 7], showControlPoints: showControlPoints)
    p.curve(g[5, 3], cp1: g[4, 5], cp2: g[4, 4], showControlPoints: showControlPoints)
    p.curve(g[6, 6], cp1: g[6, 4], cp2: g[6, 5], showControlPoints: showControlPoints)
    p.curve(g[5, 7], cp1: g[6, 7], cp2: g[5, 7], showControlPoints: showControlPoints)

//    // right
//    p.move(g[5, 8])
//    p.curve(g[4, 7], cp1: g[5, 8], cp2: g[4, 8], showControlPoints: showControlPoints)
//    p.curve(g[5, 4], cp1: g[4, 6], cp2: g[4, 5], showControlPoints: showControlPoints)
//    p.curve(g[6, 7], cp1: g[6, 5], cp2: g[6, 6], showControlPoints: showControlPoints)
//    p.curve(g[5, 8], cp1: g[6, 8], cp2: g[5, 8], showControlPoints: showControlPoints)

//    // left
//    p.move(g[2, 8])
//    p.curve(g[1, 7], cp1: g[2, 8], cp2: g[1, 8], showControlPoints: showControlPoints)
//    p.curve(g[2, 4], cp1: g[1, 6], cp2: g[1, 5], showControlPoints: showControlPoints)
//    p.curve(g[3, 7], cp1: g[3, 5], cp2: g[3, 6], showControlPoints: showControlPoints)
//    p.curve(g[2, 8], cp1: g[3, 8], cp2: g[2, 8], showControlPoints: showControlPoints)
//
//    // right
//    p.move(g[6, 8])
//    p.curve(g[5, 7], cp1: g[6, 8], cp2: g[5, 8], showControlPoints: showControlPoints)
//    p.curve(g[6, 4], cp1: g[5, 6], cp2: g[5, 5], showControlPoints: showControlPoints)
//    p.curve(g[7, 7], cp1: g[7, 5], cp2: g[7, 6], showControlPoints: showControlPoints)
//    p.curve(g[6, 8], cp1: g[7, 8], cp2: g[6, 8], showControlPoints: showControlPoints)

    return p
  }
}

extension Bristol5Shape: Pathable {}

struct Bristol5Shape_Previews: PreviewProvider {
  static var previews: some View {
    Bristol5Shape(showControlPoints: false)
      .stroke(style: strokeStyle)
      .layoutGuide(bristol5LayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
