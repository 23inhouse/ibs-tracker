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

  var body: some View {
    NavigationLink(destination: MedicationFormView(for: record)) {
      DayRowView(type: .medication, color: .secondary, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        Text(record.text ?? "No name")
          .font(.callout)
          .foregroundColor(.secondary)
          .frame(minHeight: 25, alignment: .leading)
      }
    }
  }
}

struct MedicationRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      MedicationRowView(for: IBSRecord(medication: "Perenterol", type: .probiotic, timestamp: Date(), tags: ["Perenerol"]))
      MedicationRowView(for: IBSRecord(medication: "Perenterol Enema", type: .probiotic, timestamp: Date(), tags: ["Pereneterol"]))
      MedicationRowView(for: IBSRecord(medication: "Oregano & Allicin Capsules", type: .antimicrobial, timestamp: Date(), tags: ["Oregano capsule", "Allicin capsule"]))
      MedicationRowView(for: IBSRecord(medication: "Iberogast 3 drops", type: .prokinetic, timestamp: Date(), tags: ["Iberogast"]))
      MedicationRowView(for: IBSRecord(medication: "L-Glutamine 5g", type: .suppliment, timestamp: Date(), tags: ["L-Glutamine"]))
    }
  }
}
