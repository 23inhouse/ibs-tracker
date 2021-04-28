//
//  AppIconView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import SwiftUI

struct AppIconView: View {
  var size: CGFloat = 150
  private var padding: CGFloat { size / 15 }
  private var gutSize: CGFloat { size / 3 }
  private var circleSize: CGFloat { gutSize * 1.3 }
  private var yOffset: CGFloat { size / 5 }
  private var xOffset: CGFloat { size / 50 }

  private var moodLineWidth: CGFloat { size / 50 }
  private var gutLineWidth: CGFloat { size / 80 }

  private var moodStrokeStyle: StrokeStyle { StrokeStyle(lineWidth: moodLineWidth, lineJoin: .round) }
  private var gutStrokeStyle: StrokeStyle { StrokeStyle(lineWidth: gutLineWidth, lineJoin: .round) }

  var body: some View {
    ZStack {
      MoodShape(isLighting: false)
        .stroke(style: moodStrokeStyle)
        .opacity(0.7)
        .frame(size)
        .padding(padding)
      halfBrain()
      halfBrain(degrees: 180)
    }
    .offset(x: xOffset * 2, y: 0)
  }

  func halfBrain(degrees: Double = 0) -> some View {
    BrainShape()
      .stroke(style: gutStrokeStyle)
      .rotationEffect(.degrees(degrees))
      .frame(gutSize * 0.75)
      .offset(x: xOffset, y: -yOffset * 1.3)
  }
}

struct AppIconView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      AppIconView()
    }

  }
}
