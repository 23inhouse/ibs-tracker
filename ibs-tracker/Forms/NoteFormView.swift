//
//  NoteFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct NoteFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @StateObject private var viewModel = FormViewModel()
  @State private var text: String = ""
  @State private var isFirstResponder = false

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []

  init(for noteRecord: NoteRecord? = nil) {
    guard let record = noteRecord else { return }
    self.editableRecord = noteRecord
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._text = State(initialValue: record.text ?? "")
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(timestamp: timestamp.nearest(5, .minute), note: text, tags: viewModel.tags)
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  private var savable: Bool {
    viewModel.isValidTimestamp &&
      text.isNotEmpty
  }

  var body: some View {
    FormView("Note", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        UIKitBridge.SwiftUITextView("Notes...", text: $text, isFirstResponder: isFirstResponder)
          .frame(height: 150)
          .onTapGesture {
            isFirstResponder = true
            scroller.scrollTo(id: .note)
          }
      }
      .scrollID(.note)
      .scrollID(.info)

      TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, onEditingChanged: viewModel.showTagSuggestions, scroller: scroller)

      SaveButtonSection(name: "Note", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp, scroller: scroller)
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
      suggestedTags = appState.tags(for: .note)
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

struct NoteFormView_Previews: PreviewProvider {
  static var previews: some View {
    NoteFormView()
      .environmentObject(IBSData())
  }
}
