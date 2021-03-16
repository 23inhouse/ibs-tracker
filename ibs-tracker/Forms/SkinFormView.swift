//
//  SkinFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 17/3/21.
//

import SwiftUI

struct SkinFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var condition: Scales = .none
  @State private var text: String = ""

  @State private var showAllTags: Bool = false

  init(for skinRecord: SkinRecord? = nil) {
    guard let record = skinRecord else { return }
    self.editableRecord = skinRecord
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._condition = State(initialValue: record.condition ?? .none)
    self._text = State(initialValue: record.text ?? "")
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(condition: condition, timestamp: timestamp.nearest(5, .minute), text: text, tags: viewModel.tags)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .skin)
      .sorted()
      .filter {
        let availableTag = $0.lowercased()
        return
          !viewModel.tags.contains($0) &&
          (
            showAllTags ||
              availableTag.contains(viewModel.newTag.lowercased())
          )
      }
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        ScaleSlider($condition, "Condition", descriptions: Scales.skinConditionDescriptions)
        TextEditor(text: $text)
          .frame(height: 100)
      }

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: suggestedTags, scroller: scroller)

      if condition != .none {
        SaveButtonSection(name: "Skin condition", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }
    }
  }
}

struct SkinFormView_Previews: PreviewProvider {
  static var previews: some View {
    SkinFormView()
      .environmentObject(IBSData())
  }
}