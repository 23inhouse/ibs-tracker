//
//  AcheRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 17/1/21.
//

import SwiftUI

struct AcheRowView: View {
  let record: AcheRecord

  init(for record: AcheRecord) {
    self.record = record
  }

  var body: some View {
    DayRowView(
      type: .ache,
      color: ColorCodedContent.scaleColor(for: record.acheScore()),
      tags: record.tags
    ) {
      HStack(alignment: .top, spacing: 5) {
        TimestampView(record: record as! IBSRecord)
        Spacer()
        VStack(alignment: .trailing, spacing: 5) {
          if let headache = record.headache {
            PropertyView(
              text: record.headacheText(),
              scale: headache.rawValue,
              color: ColorCodedContent.scaleColor(for: record.headache)
            )
          }
          if let bodyache = record.bodyache {
            PropertyView(
              text: record.bodyacheText(),
              scale: bodyache.rawValue,
              color: ColorCodedContent.scaleColor(for: record.bodyache)
            )
          }
        }
      }
    }
  }
}

struct AcheRowView_Previews: PreviewProvider {
  static var previews: some View {
    AcheRowView(for: IBSRecord(timestamp: Date(), tags: ["Arthritus"], headache: .moderate, bodyache: .severe))
  }
}
