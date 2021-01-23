//
//  NoteShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 19/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)
private let NoteShapeLayoutConfig = LayoutGuideConfig.grid(columns: 8, rows: 12)

struct NoteShape: Shape {
  var showControlPoints: Bool = false

  func path(in rect: CGRect) -> Path {
    var p = Path()
    let g = NoteShapeLayoutConfig.layout(in: rect)

    // outline
    p.move(g[2, 2])
    p.line(g[2, 10])
    p.curve(g[3, 11], cp1: g[2, 11], cp2: g[2, 11])
    p.line(g[5, 11])
    p.curve(g[6, 10], cp1: g[6, 11], cp2: g[6, 11])
    p.line(g[6, 3])
    p.curve(g[5, 1], cp1: g[6, 1], cp2: g[6, 1])
    p.line(g[3, 1])
    p.curve(g[2, 2], cp1: g[2, 1], cp2: g[2, 1])
    p.closeSubpath()


    // lines
    for y in [3, 4, 5, 6, 7, 8] {
      p.move(g[3, y])
      p.line(g[5, y])
    }
    p.move(g[3, 9])
    p.line(g[4, 9])

    return p
  }
}

extension NoteShape: Pathable {}

struct NoteShapeShape_Previews: PreviewProvider {
  static var previews: some View {
    NoteShape(showControlPoints: true)
      .stroke(style: strokeStyle)
      .layoutGuide(NoteShapeLayoutConfig)
      .frame(200, 200)
      .previewSizeThatFits()
      .padding(40)
      .showLayoutGuides(true)
  }
}
