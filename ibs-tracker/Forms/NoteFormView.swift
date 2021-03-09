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
    return IBSRecord(note: text, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .note).filter {
        let availableTag = $0.lowercased()
        return
          !viewModel.tags.contains($0) &&
          availableTag.contains(viewModel.newTag.lowercased())
    }
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add tag" : "Add another tag"
  }

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        TextEditor(text: $text)
          .frame(height: 200)
      }

      Section {
        List { EditableTagList(tags: $viewModel.tags) }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $viewModel.newTag, onEditingChanged: viewModel.showTagSuggestions, onCommit: viewModel.addNewTag)
          .onTapGesture { scroller.scrollToTags() }
          .onChange(of: viewModel.newTag) { _ in scroller.scrollToTags() }
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $viewModel.tags, newTag: $viewModel.newTag) }
      }
      .id(ScrollViewProxy.tagAnchor())

      if text.isNotEmpty {
        SaveButtonSection(name: "Note", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
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
