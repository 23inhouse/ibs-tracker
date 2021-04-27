//
//  BMRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

struct BMRowView: View {
  let record: BMRecord

  init(for record: BMRecord) {
    self.record = record
  }

  private var scale: BristolType {
    record.bristolScale ?? .b3
  }

  private var color: Color {
    ColorCodedContent.bristolColor(for: scale)
  }

  var body: some View {
    LazyNavigationLink(destination: BMFormView(for: record)) {
      DayRowView(record as! IBSRecord, tags: record.tags) {
        HStack {
          TimestampView(record: record as! IBSRecord)
            .frame(width: 80, alignment: .leading)
          Text(record.bristolDescription())
            .truncationMode(.middle)
            .font(.caption2)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .frame(height: 25)
            .lineLimit(1)
            .layoutPriority(1)
        }
        if let evacuation = record.evacuation {
          PropertyView(
            text: record.evacuationText(),
            scale: evacuation,
            color: ColorCodedContent.scaleColor(for: record.evacuation)
          )
        }
        if let smell = record.smell {
          PropertyView(
            text: record.smellText(),
            scale: smell,
            color: ColorCodedContent.scaleColor(for: record.smell)
          )
        }
        if let pressure = record.pressure {
          PropertyView(
            text: record.pressureText(),
            scale: pressure.rawValue,
            color: ColorCodedContent.scaleColor(for: record.pressure)
          )
        }
        if let dryness = record.dryness {
          PropertyView(
            text: record.drynessText(),
            scale: dryness.rawValue,
            color: ColorCodedContent.scaleColor(for: record.dryness)
          )
        }
        if let wetness = record.wetness {
          PropertyView(
            text: record.wetnessText(),
            scale: wetness.rawValue,
            color: ColorCodedContent.scaleColor(for: record.wetness)
          )
        }
        if let numberOf = record.numberOfBMsScale, numberOf.rawValue > 1 {
          PropertyView(
            text: record.numberOfBMsText(),
            scale: numberOf.rawValue,
            color: ColorCodedContent.scaleColor(for: numberOf)
          )
        }
      }
    }
  }
}

struct BowelMovementRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b0, tags: ["Almost sausage"]))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b1, tags: ["Almost sausage"], evacuation: .partial))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b2, tags: ["Almost sausage"], smell: .sweet, evacuation: .full, dryness: .moderate))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b3, tags: ["Almost sausage"], pressure: .mild))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b4, tags: ["Almost sausage"], evacuation: .full))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b5, tags: ["Almost sausage"], pressure: .mild, evacuation: .full, wetness: .moderate))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b6, tags: ["Almost sausage"], pressure: .moderate, wetness: .severe))
        .listRowInsets(EdgeInsets())
      BMRowView(for: IBSRecord(timestamp: Date(), bristolScale: .b7, tags: ["Almost sausage"], pressure: .severe, evacuation: .partial))
        .listRowInsets(EdgeInsets())
    }
  }
}
