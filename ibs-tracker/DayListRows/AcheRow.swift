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
      color: ColorCodedContent.scaleColor(for: record.painScore()),
      tags: record.tags
    ) {
      HStack(alignment: .top, spacing: 5) {
        TimestampView(record: record as! JSONIBSRecord)
        Spacer()
        VStack(alignment: .trailing, spacing: 5) {
          if let headache = record.headache {
            PropertyView(
              text: record.headacheText(),
              scale: headache,
              color: ColorCodedContent.scaleColor(for: record.headache)
            )
          }
          if let pain = record.pain {
            PropertyView(
              text: record.painText(),
              scale: pain,
              color: ColorCodedContent.scaleColor(for: record.pain)
            )
          }
        }
      }
    }
  }
}

struct AcheRowView_Previews: PreviewProvider {
  static var previews: some View {
    AcheRowView(for: JSONIBSRecord(date: Date(), tags: ["Arthritus"], headache: 3, pain: 4))
  }
}
