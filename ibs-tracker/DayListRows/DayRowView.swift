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
  let color: Color?
  let tags: [String]
  let bristolType: BristolType?

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  init(_ record: IBSRecord, color: Color? = .secondary, tags: [String]? = [], @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.type = record.type
    self.color = color
    self.tags = tags ?? []
    self.bristolType = record.bristolScale
  }

  var body: some View {
    HStack(alignment: .top, spacing: 5) {
      iconView
      VStack(alignment: .leading, spacing: 3) {
        contentView
        tagView
      }
      .frame(maxWidth: .infinity)
    }
    .padding(5)
  }

  var contentView: some View {
    content()
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  var iconView: some View {
    Group {
      if let bristolType = bristolType {
        BristolView(scale: bristolType)
      } else {
        RowIconView(type: type, color: color)
      }
    }
    .frame(width: 50, alignment: .center)
  }

  var tagView: some View {
    TagCloudView(tags: tags, resize: type != .food)
      .padding(.top, 3)
  }
}

struct DayRowView_Previews: PreviewProvider {
  static var previews: some View {
    DayRowView(IBSRecord(timestamp: Date(), bloating: .mild, pain: nil), color: .purple, tags: ["Foobar"]) {
      VStack(alignment: .trailing) {
        Text("My Row Content with lots and lots of c o n t e n t")
      }
    }
  }
}
