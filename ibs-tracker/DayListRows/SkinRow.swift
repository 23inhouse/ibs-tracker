//
//  SkinRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 17/3/21.
//

import SwiftUI

struct SkinRowView: View {
  let record: SkinRecord

  init(for record: SkinRecord) {
    self.record = record
  }

  private var skinConditionColor: Color {
    ColorCodedContent.skinConditionColor(for: record.skinScore())
  }

  var body: some View {
    LazyNavigationLink(destination: SkinFormView(for: record)) {
      DayRowView(record as! IBSRecord, color: skinConditionColor, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        Text(String(describing: record.text ?? ""))
          .font(.callout)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .foregroundColor(.secondary)
          .frame(minHeight: 25, alignment: .leading)
        if let skin = record.condition {
          PropertyView(
            text: record.skinText(),
            scale: skin.rawValue,
            color: ColorCodedContent.skinConditionColor(for: record.condition)
          )
        }
      }
    }
  }
}

struct SkinRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack{
      SkinRowView(for: IBSRecord(timestamp: Date(), condition: .zero, text: "Ulcer - with a second one next to it", tags: ["Ulcer"]))
      SkinRowView(for: IBSRecord(timestamp: Date(), condition: .mild, text: "No change", tags: ["Ulcer"]))
      SkinRowView(for: IBSRecord(timestamp: Date(), condition: .moderate, text: "No change", tags: ["Ulcer"]))
      SkinRowView(for: IBSRecord(timestamp: Date(), condition: .severe, text: "No change", tags: ["Ulcer"]))
      SkinRowView(for: IBSRecord(timestamp: Date(), condition: .extreme, text: "No change", tags: ["Ulcer"]))
    }
  }
}
