//
//  BristolView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct BristolView: View {
  static let defaultSize: CGFloat = 50

  let scale: BristolType
  let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)
  let frameSize: CGFloat
  let foregroundColor: Color

  init(scale: BristolType, frameSize: CGFloat = defaultSize, foregroundColor: Color? = nil) {
    self.scale = scale
    self.frameSize = frameSize
    self.foregroundColor = foregroundColor ?? ColorCodedContent.bristolColor(for: scale)
  }

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      Image(systemName: "\(scale.rawValue).circle")
        .resizedToFit()
        .frame(frameSize * 0.3)
        .offset(x: 1.25, y: 9.25)
        .opacity(frameSize < BristolView.defaultSize ? 0.25 : 1.0)
      Group {
        if scale == .b0 {
          Image(systemName: "nosign")
            .resizedToFit()
            .padding(frameSize / 6.25)
            .offset(x: 0, y: frameSize / 10)
        } else {
          BristolShape(scale: scale)
            .stroke(style: strokeStyle)
        }
      }
    }
    .foregroundColor(foregroundColor)
    .frame(frameSize, frameSize)
    .padding(.bottom, 10)
  }
}

struct BristolView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      BristolView(scale: BristolType(rawValue: 0)!)
      BristolView(scale: BristolType(rawValue: 1)!)
      BristolView(scale: BristolType(rawValue: 2)!)
      BristolView(scale: BristolType(rawValue: 3)!)
      BristolView(scale: BristolType(rawValue: 4)!)
      BristolView(scale: BristolType(rawValue: 5)!)
      BristolView(scale: BristolType(rawValue: 6)!)
      BristolView(scale: BristolType(rawValue: 7)!)
    }
  }
}
