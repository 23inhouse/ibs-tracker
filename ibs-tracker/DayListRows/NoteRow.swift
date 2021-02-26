//
//  NoteRow.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 19/1/21.
//

import SwiftUI

struct NoteRowView: View {
  let record: NoteRecord

  init(for record: NoteRecord) {
    self.record = record
  }

  private let textCountSteps: [(Int, Int, Font)] = [
    (1, 0, .caption),
    (15, 1, .body),
    (27, 3, .callout),
  ]

  private var font: Font {
    let text = (record.text ?? "")
    let textCount = text.count
    let wordCount = text.split(separator: " ").count

    for (count, words, font) in textCountSteps {
      if textCount < count && wordCount <= words {
        return font
      }
    }
    return .caption
  }

  private var text: String {
    guard record.text != nil && record.text!.count > 0 else {
      return "No note recorded"
    }
    return record.text!
  }

  var body: some View {
    NavigationLink(destination: NoteFormView(for: record)) {
      DayRowView(type: .note, color: .secondary, tags: record.tags) {
        TimestampView(record: record as! IBSRecord)
        Text(text)
          .font(font)
          .foregroundColor(.secondary)
          .frame(minHeight: 25, alignment: .leading)
      }
    }
  }
}

struct NoteRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      NoteRowView(for: IBSRecord(note: "01234567890123", timestamp: Date(), tags: []))
      NoteRowView(for: IBSRecord(note: "Sore ankle arthritis", timestamp: Date(), tags: []))
      NoteRowView(for: IBSRecord(note: "Enema w/ perenterol", timestamp: Date(), tags: []))
      NoteRowView(for: IBSRecord(note: "", timestamp: Date(), tags: []))
      NoteRowView(for: IBSRecord(note: "12345678901234567890123456", timestamp: Date(), tags: []))
      NoteRowView(for: IBSRecord(note: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo mauris, pharetra porttitor quam non, vulputate suscipit odio. Donec luctus elit eu risus tristique, at consectetur nulla pretium. Mauris a laoreet mi. In tempus ipsum a dolor sagittis, quis pulvinar ex molestie. Sed sit amet mauris maximus, lacinia nulla a, tincidunt sapien. Vivamus tincidunt nec enim a sollicitudin. Etiam bibendum, risus ut tempus rhoncus, ligula ligula faucibus justo, et consequat nisl urna quis nunc. Aenean sit amet arcu a dui tempus mollis eu cursus metus.", timestamp: Date(), tags: []))
    }
  }
}
