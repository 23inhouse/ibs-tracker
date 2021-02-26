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
  @State private var timestamp: Date? {
    didSet {
      isValidTimestamp = isValid(timestamp: timestamp)
    }
  }
  @State private var tags = [String]()
  @State private var newTag = ""
  @State private var showAlert: Bool = false
  @State private var isValidTimestamp: Bool = true
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

  private var editableTags: [String] { tags }

  private var noteRecord: NoteRecord? = nil

  private var suggestedTags: [String] {
    return
      appState.tags(for: .note).filter {
        let availableTag = $0.lowercased()
        return
          !editableTags.contains($0) &&
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
        List { editableTagList }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $newTag, onEditingChanged: showTagSuggestions, onCommit: addNewTag)
        List { suggestedTagList }
      }

      if text.isNotEmpty {
        insertOrUpdateButtonSection
          .disabled(!isValidTimestamp)
      }

      Section {
        datePicker
      }
      .modifierIf(!isValidTimestamp) {
        $0
          .listRowBackground(Color(red: 1, green: 0, blue: 0, opacity: 0.333))
          .opacity(0.8)
      }
    }
    .onAppear() {
      guard timestamp == nil else { return }
      timestamp = Date().nearest(5, .minute)
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        if editMode {
          Button(action: {
            showAlert = true
          }, label: {
            Image(systemName: "trash")
          })
        }
      }
    }
    .alert(isPresented: $showAlert) { deleteAlert }
    .gesture(DragGesture().onChanged { _ in endEditing(true) })
  }

  private var datePicker: some View {
    UIKitBridge.SwiftUIDatePicker(selection: $timestamp, range: nil, minuteInterval: 5)
      .onChange(of: timestamp) { value in
        timestamp = value
      }
  }

  private var deleteAlert: Alert {
    Alert(
      title: Text("Are you sure?"),
      message: Text("This will delete the item"),
      primaryButton: .default (Text("OK")) {
        delete {
          DispatchQueue.main.async {
            appState.tabSelection = .day
            presentation.wrappedValue.dismiss()
          }
        }
      },
      secondaryButton: .cancel()
    )
  }

  private var editableTagList: some View {
    ForEach(tags.indices, id: \.self) { i in
      if editableTags.indices.contains(i) {
        HStack {
          TextField("", text: Binding(
            get: { self.tags[i] },
            set: { self.tags[i] = $0 }
          ))

          Button(action: {
            tags.remove(at: i)
          }, label: {
            Image(systemName: "xmark.circle")
          })
        }
      }
    }
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

  private var suggestedTagList: some View {
    List {
      ForEach(suggestedTags, id: \.self) { value in
        Button(value) {
          tags.append(value)
          newTag = ""
        }
      }
    }
  }

  private func addNewTag() {
    let answer = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 0 else { return }

    tags.append(answer)
    newTag = ""
  }

  private func delete(completionHandler: () -> Void) {
    completionHandler()

    DispatchQueue.global(qos: .utility).async {
      do {
        guard let record = noteRecord as? IBSRecord else { return }
        try record.deleteSQL(into: AppDB.current)
        DispatchQueue.main.async {
          appState.reloadRecordsFromSQL()
        }
      } catch {
        print("Error: \(error)")
      }
    }
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

  private func isValid(timestamp: Date?) -> Bool {
    guard let timestamp = timestamp else { return false }

    return appState.isAvailable(timestamp: timestamp)
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
