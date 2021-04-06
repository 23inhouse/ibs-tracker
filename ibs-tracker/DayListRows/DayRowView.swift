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
  let medicinal: Bool

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  init(_ record: IBSRecord, color: Color? = .secondary, tags: [String]? = [], @ViewBuilder content: @escaping () -> Content) {
    self.content = content
    self.type = record.type
    self.color = color
    self.tags = tags ?? []
    self.bristolType = record.bristolScale
    self.medicinal = record.medicinal ?? false
  }

  var body: some View {
    HStack(alignment: .top, spacing: 5) {
      iconView
        .padding(.vertical, 7)
      VStack(alignment: .leading, spacing: 3) {
        contentView
        tagView
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding(.leading, 24)
          .padding(.top, 3)
          .padding(.trailing, 5)
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
        RowIconView(type: type, color: color, medicinal: medicinal)
      }
    }
    .frame(width: 50, height: 50)
  }

  var tagView: some View {
    TagCloudView(tags: tags, resize: type != .food)
  }
}

struct DayRowView_Previews: PreviewProvider {
  static let record = IBSRecord(timestamp: Date(), bloating: .mild, pain: nil)
  static var previews: some View {
    List {
      DayRowView(record, color: .purple, tags: ["Foobar"]) {
        TimestampView(record: IBSRecord(condition: .moderate, timestamp: Date()))
        Text("My Row Content with lots and lots of c o n t e n t")
        PropertyView(
          text: record.bloatingText(),
          scale: record.bloating!.rawValue,
          color: ColorCodedContent.scaleColor(for: record.bloating
          )
        )
      }
    }
  }
}
