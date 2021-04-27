//
//  MedicationRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 22/1/21.
//

import SwiftUI

struct MedicationRowView: View {
  let record: MedicationRecord

  init(for record: MedicationRecord) {
    self.record = record
  }

  private var medicationNames: String {
    guard let medicationTypes = record.medicationType else { return "" }

    return medicationTypes.map { $0.rawValue.capitalizeFirstLetter() }.joined(separator: ", ")
  }

  var body: some View {
    LazyNavigationLink(destination: MedicationFormView(for: record)) {
      DayRowView(record as! IBSRecord, color: .secondary, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        Text(record.text ?? "No name")
          .font(.callout)
          .foregroundColor(.secondary)
          .frame(minHeight: 25, alignment: .leading)
        Text(medicationNames)
          .font(.caption)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding(.leading, 24)
          .padding(.trailing, 5)
      }
    }
  }
}

struct MedicationRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      MedicationRowView(for: IBSRecord(timestamp: Date(), medication: "Perenterol", type: [.probiotic], tags: ["Perenerol"]))
      MedicationRowView(for: IBSRecord(timestamp: Date(), medication: "Perenterol Enema", type: [.probiotic], tags: ["Pereneterol"]))
      MedicationRowView(for: IBSRecord(timestamp: Date(), medication: "Oregano & Allicin Capsules", type: [.antimicrobial], tags: ["Oregano capsule", "Allicin capsule"]))
      MedicationRowView(for: IBSRecord(timestamp: Date(), medication: "Iberogast 3 drops", type: [.prokinetic], tags: ["Iberogast"]))
      MedicationRowView(for: IBSRecord(timestamp: Date(), medication: "L-Glutamine 5g", type: [.suppliment], tags: ["L-Glutamine"]))
    }
  }
}
