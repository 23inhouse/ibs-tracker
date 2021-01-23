//
//  FoodShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let FoodLayoutConfig = LayoutGuideConfig.grid(columns: 24, rows: 24)

struct FoodShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = FoodLayoutConfig.layout(in: rect)

    // drink
    p.move(g[12, 4])
    p.line(g[24, 4])
    p.line(g[22, 24])
    p.line(g[14, 24])
    p.closeSubpath()

    // straw
    p.move(g[17, 4])
    p.line(g[17, -1])
    p.line(g[19, -1])
    p.line(g[19, 4])
    p.closeSubpath()

    // bottom bun
    p.move(g[6, 22])
    p.line(g[14, 22])
    p.move(g[2, 18])
    p.line(g[2, 18])
    p.curve(g[6, 22], cp1: g[1, 22], cp2: g[6, 22], showControlPoints: showControlPoints)
//    p.closeSubpath()

    // top bun
    p.move(g[10, 8])
    p.line(g[12, 8])
    p.move(g[13, 14])
    p.line(g[2, 14])
    p.curve(g[10, 8], cp1: g[1, 8], cp2: g[10, 8], showControlPoints: showControlPoints)
//    p.closeSubpath()

    // patty
    p.move(g[2, 18])
    p.line(g[13, 18])
    p.move(g[13, 14])
    p.line(g[2, 14])
    p.curve(g[2, 18], cp1: g[0, 14], cp2: g[0, 18], showControlPoints: showControlPoints)
//    p.closeSubpath()




//    // bowl
//    p.move(g[4, 12])
//    p.curve(g[7, 6], cp1: g[7, 12], cp2: g[8, 11], showControlPoints: showControlPoints)
//    p.move(g[1, 6])
//    p.curve(g[4, 12], cp1: g[0, 11], cp2: g[1, 12], showControlPoints: showControlPoints)
//
//    // rice
//    p.move(g[4, 4])
//    p.curve(g[7, 6], cp1: g[6, 4], cp2: g[7, 5], showControlPoints: showControlPoints)
//    p.curve(g[4, 7], cp1: g[7, 7], cp2: g[6, 7], showControlPoints: showControlPoints)
//    p.curve(g[1, 6], cp1: g[2, 7], cp2: g[1, 7], showControlPoints: showControlPoints)
//    p.curve(g[4, 4], cp1: g[1, 5], cp2: g[2, 4], showControlPoints: showControlPoints)
//
//    // chopsticks
//    p.move(g[6, 0])
//    p.line(g[4, 6])
//    p.move(g[7, 1])
//    p.line(g[5, 6])

    return p
  }
}

extension FoodShape: Pathable {}

struct FoodShape_Previews: PreviewProvider {
  static var previews: some View {
    FoodShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(FoodLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
