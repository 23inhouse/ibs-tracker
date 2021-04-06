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

  private var acheColor: Color {
    ColorCodedContent.scaleColor(for: record.acheScore())
  }

  var body: some View {
    LazyNavigationLink(destination: AcheFormView(for: record)) {
      DayRowView(record as! IBSRecord, color: acheColor, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
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

struct AcheRowView_Previews: PreviewProvider {
  static var previews: some View {
    AcheRowView(for: IBSRecord(timestamp: Date(), tags: ["Arthritus"], headache: .moderate, bodyache: .severe))
  }
}
