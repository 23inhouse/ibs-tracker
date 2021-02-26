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
    self.noteRecord = noteRecord
    guard let record = noteRecord else { return }
    self._text = State(initialValue: record.text ?? "")
    self._timestamp = State(initialValue: record.timestamp)
    self._tags = State(initialValue: record.tags)
  }

  private var editMode: Bool {
    get { noteRecord != nil }
  }

  private var noteRecord: NoteRecord? = nil

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
        insertOrUpdateButtonSection
          .disabled(!isValidTimestamp)
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
    .alert(delete: noteRecord as? IBSRecord, appState: appState, isPresented: $showAlert) {
      DispatchQueue.main.async {
        appState.tabSelection = .day
        presentation.wrappedValue.dismiss()
      }
    }
    .gesture(DragGesture().onChanged { _ in endEditing(true) })
  }

  private var insertOrUpdateButtonSection: some View {
    Section {
      Button(action: {
        insertOrUpdate {
          DispatchQueue.main.async {
            appState.tabSelection = .day
            presentation.wrappedValue.dismiss()
          }
        }
      }) {
        Text(editMode ? "Update note" : "Add note")
          .frame(maxWidth: .infinity)
      }
    }
    .modifierIf(isValidTimestamp) {
      $0
        .listRowBackground(Color.blue)
        .foregroundColor(.white)
    }
    .modifierIf(!isValidTimestamp) {
      $0
        .listRowBackground(Color.secondary)
        .opacity(0.8)
        .foregroundColor(Color(red: 1, green: 0, blue: 0, opacity: 0.333))
    }
  }

  private func addNewTag() {
    let answer = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 0 else { return }

    tags.append(answer)
    newTag = ""
  }

  private func insertOrUpdate(completionHandler: @escaping () -> Void) {
    completionHandler()

    DispatchQueue.global(qos: .userInteractive).async {
      do {
        guard let timestamp = timestamp else { return }
        let record = IBSRecord(note: text, timestamp: timestamp.nearest(5, .minute), tags: tags)

        if let noteRecord = noteRecord {
          try record.updateSQL(into: AppDB.current, timestamp: noteRecord.timestamp)
        } else {
          try record.insertSQL(into: AppDB.current)
        }
        DispatchQueue.main.async { appState.reloadRecordsFromSQL() }
      } catch {
        print("Error: \(error)")
      }
    }
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
