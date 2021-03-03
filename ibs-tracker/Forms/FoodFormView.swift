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

  @StateObject private var viewModel = FormViewModel()
  @State private var name: String = ""
  @State private var size: FoodSizes = .none
  @State private var risk: Scales = .none
  @State private var recentFoodSelection: IBSRecord?
  @State private var nameIsCompleted: Bool = false
  @State private var tagIsFirstResponder: Bool = false

  init(for foodRecord: FoodRecord? = nil) {
    guard let record = foodRecord else { return }
    self.editableRecord = record
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._name = State(initialValue: record.text ?? "")
    self._size = State(initialValue: record.size ?? .none)
    self._risk = State(initialValue: record.risk ?? .none)
    self._nameIsCompleted = State(initialValue: true)
  }

  private var editMode: Bool { editableRecord != nil }
  private var editableRecord: IBSRecordType? = nil

  private var recentFoodPlaceholder: String {
    name.isEmpty && viewModel.tags.isEmpty ? "Choose from recent meals" : "Replace with recent meal"
  }

  private var recentFoods: [IBSRecord] {
    appState.recentRecords(of: .food)
  }

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(food: name, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, risk: risk, size: size)
  }

  private var suggestedTags: [String] {
    return
      appState.tags(for: .food).filter {
        let availableTag = $0.lowercased()
        return
          nameIsCompleted &&
          !viewModel.tags.contains($0) &&
          (
            availableTag.contains(viewModel.newTag.lowercased()) ||
              name.split(separator: " ").filter {
                let word = String($0.lowercased())
                return
                  word.count > 2 &&
                  viewModel.tags.filter { $0.lowercased().contains(word) }.isEmpty &&
                  (availableTag.contains(word) || word.contains(availableTag))
              }.isNotEmpty
          )
    }
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add ingredient" : "Add another ingredient"
  }

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) {
      Section {
        UIKitBridge.SwiftUITextField("Meal name. e.g. Pizza", text: $name, onCommit: commitName)

        List { EditableTagList(tags: $viewModel.tags) }
        UIKitBridge.SwiftUITextField(tagPlaceholder, text: $viewModel.newTag, isFirstResponder: tagIsFirstResponder, onEditingChanged: viewModel.showTagSuggestions, onCommit: viewModel.addNewTag)
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $viewModel.tags, newTag: $viewModel.newTag) }
      }

      if recentFoods.isNotEmpty {
        recentFoodSection
      }

      Section {
        ScaleSlider($size, "Size", descriptions: FoodSizes.descriptions)
        ScaleSlider($risk, "Risk", descriptions: Scales.foodRiskDescriptions)
      }

      if name.isNotEmpty && viewModel.tags.isNotEmpty {
        SaveButtonSection(name: "Meal", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }
    }
  }

  private var datePicker: some View {
    UIKitBridge.SwiftUIDatePicker(selection: $viewModel.timestamp, range: nil, minuteInterval: 5)
      .onChange(of: viewModel.timestamp) { value in
        viewModel.timestamp = value
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
        viewModel.tags = record.tags
        recentFoodSelection = nil
      }
    }
  }

  private func commitName() {
    nameIsCompleted = true
    tagIsFirstResponder = true
    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5) {
      tagIsFirstResponder = false
    }
  }
}

struct FoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    FoodFormView()
      .environmentObject(IBSData())
  }
}
