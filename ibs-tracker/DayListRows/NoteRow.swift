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
    DayRowView(type: .note, color: .secondary, tags: record.tags) {
      TimestampView(record: record as! JSONIBSRecord)
      Text(text)
        .font(font)
        .foregroundColor(.secondary)
        .frame(minHeight: 25, alignment: .leading)
    }
  }
}

struct NoteRowView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      NoteRowView(for: JSONIBSRecord(note: "01234567890123", date: Date(), tags: []))
      NoteRowView(for: JSONIBSRecord(note: "Sore ankle arthritis", date: Date(), tags: []))
      NoteRowView(for: JSONIBSRecord(note: "Enema w/ perenterol", date: Date(), tags: []))
      NoteRowView(for: JSONIBSRecord(note: "", date: Date(), tags: []))
      NoteRowView(for: JSONIBSRecord(note: "12345678901234567890123456", date: Date(), tags: []))
      NoteRowView(for: JSONIBSRecord(note: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo mauris, pharetra porttitor quam non, vulputate suscipit odio. Donec luctus elit eu risus tristique, at consectetur nulla pretium. Mauris a laoreet mi. In tempus ipsum a dolor sagittis, quis pulvinar ex molestie. Sed sit amet mauris maximus, lacinia nulla a, tincidunt sapien. Vivamus tincidunt nec enim a sollicitudin. Etiam bibendum, risus ut tempus rhoncus, ligula ligula faucibus justo, et consequat nisl urna quis nunc. Aenean sit amet arcu a dui tempus mollis eu cursus metus.", date: Date(), tags: []))
    }
  }
}
