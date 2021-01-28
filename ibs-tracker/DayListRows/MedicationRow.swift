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
    DayRowView(type: .medication, color: .secondary, tags: record.tags) {
      TimestampView(record: record as! JSONIBSRecord)
      Text(record.text ?? "No name")
        .font(.callout)
        .foregroundColor(.secondary)
        .frame(minHeight: 25, alignment: .leading)
    }
  }
}

struct MedicationRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      MedicationRowView(for: JSONIBSRecord(medication: "Perenterol", type: .probiotics, date: Date(), tags: ["Perenerol"]))
      MedicationRowView(for: JSONIBSRecord(medication: "Perenterol Enema", type: .probiotics, date: Date(), tags: ["Pereneterol"]))
      MedicationRowView(for: JSONIBSRecord(medication: "Oregano & Allicin Capsules", type: .antimicrobial, date: Date(), tags: ["Oregano capsule", "Allicin capsule"]))
      MedicationRowView(for: JSONIBSRecord(medication: "Iberogast 3 drops", type: .prokinetic, date: Date(), tags: ["Iberogast"]))
      MedicationRowView(for: JSONIBSRecord(medication: "L-Glutamine 5g", type: .suppliment, date: Date(), tags: ["L-Glutamine"]))
    }
  }
}
