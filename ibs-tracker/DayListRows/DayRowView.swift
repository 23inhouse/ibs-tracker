//
//  DayRowView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct DayRowView<Content>: View where Content: View {
  let content: () -> Content
  let type: ItemType
  let bristolType: BristolType
  let color: Color?
  let tags: [String]

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  init(type: ItemType, color: Color, bristolScale: BristolType? = nil, tags: [String]? = [], @ViewBuilder content: @escaping () -> Content) {
    self.type = type
    self.bristolType = bristolScale ?? .b4
    self.color = color
    self.content = content
    self.tags = tags ?? []
  }

  var body: some View {
    HStack(alignment: .top, spacing: 5) {
      iconView
      VStack(alignment: .leading, spacing: 3) {
        content()
          .frame(maxWidth: .infinity, alignment: .leading)
        TagCloudView(tags: tags, resize: type != .food)
          .padding(.top, 3)
      }
      .frame(maxWidth: .infinity)
    }
    .padding(5)
  }

  var iconView: some View {
    Group {
      if type == .bm {
        BristolView(scale: bristolType)
      } else {
        RowIconView(type: type, color: color)
      }
    }
    .frame(width: 50, alignment: .center)
  }
}

struct DayRowView_Previews: PreviewProvider {
  static var previews: some View {
    DayRowView(type: .gut, color: .purple, tags: ["Foobar"]) {
      VStack(alignment: .trailing) {
        Text("My Row Content with lots and lots of c o n t e n t")
      }
    }
  }
}
