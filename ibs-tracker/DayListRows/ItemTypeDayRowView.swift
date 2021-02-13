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
    case .bm: BowelMovementRowView(for: record)
    case .food: FoodRowView(for: record)
    case .gut: GutSymptomRowView(for: record)
    case .medication: MedicationRowView(for: record)
    case .mood: MoodRowView(for: record)
    case .note: NoteRowView(for: record)
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
      ItemTypeDayRowView(record: IBSRecord(bristolScale: 3, timestamp: Date(), tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(food: "Meal name", timestamp: Date(), tags: ["tag"], risk: 2, size: 4))
      ItemTypeDayRowView(record: IBSRecord(note: "A custome note", timestamp: Date(), tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(medication: "Vitamin", type: .probiotic, timestamp: Date(), tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(weight: 60, timestamp: Date(), tags: ["tag"]))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), tags: ["tag"], bloating: 1, pain: 2))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), tags: ["tag"], headache: 2, bodyache: 3))
      ItemTypeDayRowView(record: IBSRecord(timestamp: Date(), tags: ["tag"], feel: 4, stress: 5))
    }
  }
}
