//
//  FoodFormView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 11/2/21.
//

import SwiftUI

struct FoodFormView: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  @State private var name: String = ""
  @State private var timestamp: Date?
  @State private var isValidTimestamp: Bool = true
  @State private var size: FoodSizes = .none
  @State private var risk: Scales = .none
  @State private var tags = [String]()
  @State private var newTag = ""
  @State private var recentFoodSelection: IBSRecord?
  @State private var showAlert: Bool = false
  @State private var nameIsCompleted: Bool = false
  @State private var isEditingTags: Bool = false
  @State private var tagIsFirstResponder: Bool = false

  init(for foodRecord: FoodRecord? = nil) {
    guard let record = foodRecord else { return }
    self.editableRecord = record
    self._name = State(initialValue: record.text ?? "")
    self._timestamp = State(initialValue: record.timestamp)
    self._size = State(initialValue: record.size ?? .none)
    self._risk = State(initialValue: record.risk ?? .none)
    self._tags = State(initialValue: record.tags)
    self._nameIsCompleted = State(initialValue: true)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var nameIsFirstResponder: Bool { name.isEmpty && !nameIsCompleted && !isEditingTags }

  private var recentFoodPlaceholder: String {
    name.isEmpty && tags.isEmpty ? "Choose from recent meals" : "Replace with recent meal"
  }

  private var recentFoods: [IBSRecord] {
    appState.recentRecords(of: .food)
  }

  private var record: IBSRecord? {
    guard let timestamp = timestamp else { return nil }
    return IBSRecord(food: name, timestamp: timestamp.nearest(5, .minute), tags: tags, risk: risk, size: size)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .food).filter {
        let availableTag = $0.lowercased()
        return
          nameIsCompleted &&
          !tags.contains($0) &&
          (
            availableTag.contains(newTag.lowercased()) ||
              name.split(separator: " ").filter {
                let word = String($0.lowercased())
                return
                  word.count > 2 &&
                  tags.filter { $0.lowercased().contains(word) }.isEmpty &&
                  (availableTag.contains(word) || word.contains(availableTag))
              }.isNotEmpty
          )
    }
  }

  private var tagPlaceholder: String {
    tags.isEmpty ? "Add ingredient" : "Add another ingredient"
  }

  var body: some View {
    Form {
      if recentFoods.isNotEmpty {
        recentFoodSection
      }

      Section {
        UIKitBridge.SwiftUITextField("Meal name. e.g. Pizza", text: $name, isFirstResponder: nameIsFirstResponder, onCommit: commitName)

        List { EditableTagList(tags: $tags) }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $newTag, isFirstResponder: tagIsFirstResponder, onEditingChanged: showTagSuggestions, onCommit: addNewTag)
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $tags, newTag: $newTag) }
      }

      Section {
        sizePicker
        riskPicker
      }

      if name.isNotEmpty && tags.isNotEmpty {
        SaveButtonSection(name: "Meal", record: record, isValidTimestamp: isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
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

  private var datePicker: some View {
    UIKitBridge.SwiftUIDatePicker(selection: $timestamp, range: nil, minuteInterval: 5)
      .onChange(of: timestamp) { value in
        timestamp = value
      }
  }

  private var recentFoodSection: some View {
    Section {
      Picker(recentFoodPlaceholder, selection: $recentFoodSelection) {
        ForEach(recentFoods, id: \.self) { record in
          VStack(alignment: .leading) {
            Text(record.text ?? "")
            TagCloudView(tags: record.tags)
          }.tag(record as IBSRecord?)
        }
      }
      .onChange(of: recentFoodSelection) { record in
        guard let record = record else { return }
        name = record.text ?? ""
        tags = record.tags
        recentFoodSelection = nil
      }
    }
  }

  private var riskPicker: some View {
    Picker("Risk", selection: $risk) {
      ForEach(Scales.allCases, id: \.self) { scale in
        VStack(alignment: .leading) {
          Text(Scales.foodRiskDescriptions[scale]?.capitalized ?? "")
        }.tag(scale)
      }
    }
  }

  private var sizePicker: some View {
    Picker("Size", selection: $size) {
      ForEach(FoodSizes.allCases, id: \.self) { foodSize in
        Text(FoodSizes.descriptions[foodSize]?.capitalized ?? "")
          .tag(foodSize)
      }
    }
  }

  private func addNewTag() {
    let answer = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
    guard answer.count > 0 else { return }

    tags.append(answer)
    newTag = ""
  }

  private func commitName() {
    nameIsCompleted = true
    tagIsFirstResponder = true
    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5) {
      tagIsFirstResponder = false
    }
  }

  private func showTagSuggestions(_ isEditing: Bool) {
    isEditingTags = isEditing
  }
}

struct FoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    FoodFormView()
      .environmentObject(IBSData())
  }
}
