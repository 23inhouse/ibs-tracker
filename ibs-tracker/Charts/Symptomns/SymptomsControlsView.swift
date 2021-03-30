//
//  SymptomsControlsView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 29/3/21.
//

import SwiftUI

struct SymptomsControlsView: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var include: [ItemType]

  var resetAction: () -> Void

  private let options: [ItemType] = [.bm, .gut, .ache, .mood, .skin]
  private let strokeStyle = StrokeStyle(lineWidth: 1.0, lineJoin: .round)

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  var body: some View {
    VStack {
      ForEach(options, id: \.self) { itemType in
        TypeShape(type: itemType)
          .stroke(style: strokeStyle)
          .scaledToFit()
          .rotate(.degrees(90))
          .frame(25)
          .foregroundColor(include.contains(itemType) ? .blue : .secondary)
          .backgroundColor(backgroundColor)
          .padding(.vertical, 5)
          .padding(.horizontal, 2)
          .onTapGesture {
            include.toggle(on: !include.contains(itemType), element: itemType)
          }
      }
      Button(action: resetAction) {
        Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
      }
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 18)
    .background(
      RoundedRectangle(cornerRadius: 20)
        .stroke(Color.secondary, lineWidth: 0.5)
        .backgroundColor(backgroundColor)
        .cornerRadius(20)
    )
    .padding(.horizontal, 10)
    .padding(.vertical, 35)
  }
}

struct SymptomsControlsView_Previews: PreviewProvider {
  static var previews: some View {
    SymptomsControlsView(include: Binding.constant([.bm, .gut]), resetAction: {})
  }
}
