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
    ItemTypeDayRowView(record: IBSRecord(bristolScale: 3, date: Date()))
  }
}
