//
//  ItemTypeDayRowView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct ItemTypeDayRowView: View {
  var record: IBSRecord

  var body: some View {
    switch record.type {
    case .ache: AcheRowView(for: record)
    case .bm: BMRowView(for: record)
    case .food: FoodRowView(for: record)
    case .gut: GutSymptomRowView(for: record)
    case .medication: MedicationRowView(for: record)
    case .mood: MoodRowView(for: record)
    case .note: NoteRowView(for: record)
    case .skin: SkinRowView(for: record)
    case .weight: WeightRowView(for: record)
    default:
      Text("Unknown type: [\(record.type.rawValue)]")
        .font(.footnote)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
    }
  }
}

struct ItemTypeDayRowView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), bristolScale: .b3, tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), food: "Meal name", tags: ["tag"], risk: .mild, size: .large, speed: Scales.none))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), note: "A custome note", tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), medication: "Vitamin", type: [.probiotic], tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), weight: 60, tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), tags: ["tag"], bloating: .mild, pain: .moderate))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), tags: ["tag"], headache: .moderate, bodyache: .severe))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), tags: ["tag"], feel: .awful, stress: .extreme))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), condition: .moderate, text: "no change", tags: ["Ulcer"]))
    }
  }
}
