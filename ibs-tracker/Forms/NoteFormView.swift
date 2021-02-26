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

  @State private var text: String = ""
  @State private var timestamp: Date?
  @State private var isValidTimestamp: Bool = true
  @State private var tags = [String]()
  @State private var newTag = ""
  @State private var showAlert: Bool = false
  @State private var isEditingTags: Bool = false

  init(for noteRecord: NoteRecord? = nil) {
    guard let record = noteRecord else { return }
    self.editableRecord = noteRecord
    self._text = State(initialValue: record.text ?? "")
    self._timestamp = State(initialValue: record.timestamp)
    self._tags = State(initialValue: record.tags)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var record: IBSRecord? {
    guard let timestamp = timestamp else { return nil }
    return IBSRecord(note: text, timestamp: timestamp.nearest(5, .minute), tags: tags)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .note).filter {
        let availableTag = $0.lowercased()
        return
          !tags.contains($0) &&
          availableTag.contains(newTag.lowercased())
    }
  }

  private var tagPlaceholder: String {
    tags.isEmpty ? "Add tag" : "Add another tag"
  }

  var body: some View {
    Form {
      Section {
        TextEditor(text: $text)
          .frame(height: 200)
      }

      Section {
        List { EditableTagList(tags: $tags) }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $newTag, onEditingChanged: showTagSuggestions, onCommit: addNewTag)
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $tags, newTag: $newTag) }
      }

      if text.isNotEmpty {
        SaveButtonSection(name: "Note", record: record, isValidTimestamp: isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }

      DatePickerSectionView(timestamp: $timestamp, isValidTimestamp: $isValidTimestamp)
    }
    .onAppear() {
      guard timestamp == nil else { return }
      timestamp = Date().nearest(5, .minute)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      DeleteRecordToolbarItem(editMode: editMode, showAlert: $showAlert)
    }
    .alert(delete: editableRecord, appState: appState, isPresented: $showAlert) {
      DispatchQueue.main.async {
        appState.tabSelection = .day
        presentation.wrappedValue.dismiss()
      }
    }
    .gesture(DragGesture().onChanged { _ in endEditing(true) })
  }

  private func addNewTag() {
    let answer = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 0 else { return }

    tags.append(answer)
    newTag = ""
  }

  private func showTagSuggestions(_ isEditing: Bool) {
    isEditingTags = isEditing
  }
}

struct NoteFormView_Previews: PreviewProvider {
  static var previews: some View {
    NoteFormView()
      .environmentObject(IBSData())
  }
}
