//
//  AppIconView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import SwiftUI

struct AppIconView: View {
  @Environment(\.colorScheme) var colorScheme

  private let size: CGFloat = 150
  private var padding: CGFloat { size / 15 }
  private var gutSize: CGFloat { size / 3 }
  private var circleSize: CGFloat { gutSize * 1.3 }
  private var yOffset: CGFloat { size / 5 }
  private var xOffset: CGFloat { size / 50 }

  private var moodLineWidth: CGFloat { size / 50 }
  private var gutLineWidth: CGFloat { size / 100 }

  private var moodStrokeStyle: StrokeStyle { StrokeStyle(lineWidth: moodLineWidth, lineJoin: .round) }
  private var gutStrokeStyle: StrokeStyle { StrokeStyle(lineWidth: gutLineWidth, lineJoin: .round) }

  private var foregroundColor: Color { colorScheme == .dark ? .secondary : .primary }
  var body: some View {
    ZStack {
      MoodShape(isLighting: false)
        .stroke(style: moodStrokeStyle)
        .frame(size)
        .padding(padding)
      Circle()
        .stroke(style: gutStrokeStyle)
        .frame(circleSize)
        .offset(x: xOffset, y: -yOffset)
      GutShape()
        .stroke(style: gutStrokeStyle)
        .frame(gutSize)
        .offset(x: xOffset, y: -yOffset)
    }
    .foregroundColor(foregroundColor)
  }
}

struct AppIconView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      AppIconView()
      AppIconView()
        .colorScheme(.dark)
    }

  }
}
