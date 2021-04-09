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
  @State private var suggestedTags: [String] = []

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

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  private var savable: Bool {
    viewModel.isValidTimestamp &&
      condition != .none
  }

  var body: some View {
    FormView("Skin condition", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        ScaleSlider($condition, "Condition", descriptions: Scales.skinConditionDescriptions)
        TextEditor(text: $text)
          .frame(height: 100)
          .onTapGesture {
            viewModel.scrollTo(1, scroller: scroller)
          }
      }
      .id(1)

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, onEditingChanged: viewModel.showTagSuggestions, scroller: scroller)

      SaveButtonSection(name: "Skin condition", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp)
    }
    .onAppear {
      calcSuggestedTags()
    }
    .onChange(of: [showAllTags]) { _ in
      calcSuggestedTags()
    }
    .onChange(of: [viewModel.tags, [viewModel.newTag]]) { _ in
      calcSuggestedTags()
    }
  }

  private func calcSuggestedTags() {
    DispatchQueue.main.async {
      suggestedTags = appState.tags(for: .skin)
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
  }
}

struct SkinFormView_Previews: PreviewProvider {
  static var previews: some View {
    SkinFormView()
      .environmentObject(IBSData())
  }
}
