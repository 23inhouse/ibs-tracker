//
//  BristolView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct BristolView: View {
  let scale: BristolType?
  let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)
  let frameSize: CGFloat = 50

  var body: some View {
    Group {
      if [nil, .b0].contains(scale) {
        Image(systemName: "nosign")
          .resizedToFit()
          .padding(8)
      } else {
        BristolShape(scale: scale ?? .b4)
          .stroke(style: strokeStyle)
      }
    }
    .foregroundColor(ColorCodedContent.bristolColor(for: scale?.rawValue ?? 0))
    .frame(frameSize, frameSize)
  }
}

struct BristolView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      BristolView(scale: BristolType(rawValue: 0))
      BristolView(scale: BristolType(rawValue: 1))
      BristolView(scale: BristolType(rawValue: 2))
      BristolView(scale: BristolType(rawValue: 3))
      BristolView(scale: BristolType(rawValue: 4))
      BristolView(scale: BristolType(rawValue: 5))
      BristolView(scale: BristolType(rawValue: 6))
      BristolView(scale: BristolType(rawValue: 7))
    }
  }
}
