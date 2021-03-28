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
  @State private var medicinal: Bool = false
  @State private var recentFoodSelection: IBSRecord?
  @State private var isEditingName: Bool = false
  @State private var nameIsCompleted: Bool = false
  @State private var tagIsFirstResponder: Bool = false

  @State private var showAllTags: Bool = false

  let tagAutoScrollLimit = 3

  init(for foodRecord: FoodRecord? = nil) {
    guard let record = foodRecord else { return }
    self.editableRecord = record
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._name = State(initialValue: record.text ?? "")
    self._size = State(initialValue: record.size ?? .none)
    self._risk = State(initialValue: record.risk ?? .none)
    self._medicinal = State(initialValue: record.medicinal ?? false)
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
    return IBSRecord(food: name, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, risk: risk, size: size, medicinal: medicinal)
  }

  private var suggestedTags: [String] {
    guard !isEditingName else { return [] }
    return
      appState.tags(for: .food)
      .sorted()
      .filter {
        let availableTag = $0.lowercased()
        return
          !viewModel.tags.contains($0) &&
          (
            availableTag.contains(viewModel.newTag.lowercased()) ||
            (
              nameIsCompleted &&
              name.split(separator: " ").filter {
                let word = String($0.lowercased())
                return
                  word.count > 2 &&
                  viewModel.tags.filter { $0.lowercased().contains(word) }.isEmpty &&
                  (availableTag.contains(word) || word.contains(availableTag))
              }.isNotEmpty
            )
        )
    }
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add ingredient" : "Add another ingredient"
  }

  var body: some View {
    FormView(viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        UIKitBridge.SwiftUITextFieldView("Meal name. e.g. Pizza", text: $name, onEditingChanged: editName, onCommit: commitName)
          .onTapGesture {
            viewModel.scrollToTags(scroller: scroller)
          }

        List { EditableTagList(tags: $viewModel.tags) }
        UIKitBridge.SwiftUITextFieldView(tagPlaceholder, text: $viewModel.newTag, isFirstResponder: tagIsFirstResponder, onEditingChanged: viewModel.showTagSuggestions, onCommit: viewModel.addNewTag)
          .onTapGesture {
            commitName()
            viewModel.scrollToTags(scroller: scroller)
          }
          .onChange(of: viewModel.newTag) { _ in viewModel.scrollToTags(scroller: scroller) }
        List { SuggestedTagList(suggestedTags: suggestedTags, tags: $viewModel.tags, newTag: $viewModel.newTag, showAllTags: $showAllTags) }
      }
      .id(ScrollViewProxy.tagAnchor())

      if recentFoods.isNotEmpty {
        recentFoodSection
      }

      Section {
        ScaleSlider($size, "Size", descriptions: FoodSizes.descriptions)
        ScaleSlider($risk, "Risk", descriptions: Scales.foodRiskDescriptions)
        Toggle("Medicinal", isOn: $medicinal)
      }

      if name.isNotEmpty && viewModel.tags.isNotEmpty {
        SaveButtonSection(name: "Meal", record: record, isValidTimestamp: viewModel.isValidTimestamp, editMode: editMode, editTimestamp: editableRecord?.timestamp)
      }
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
    isEditingName = false
    nameIsCompleted = true
    tagIsFirstResponder = true
    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5) {
      tagIsFirstResponder = false
    }
  }

  private func editName(_ isEditing: Bool) {
    isEditingName = isEditing
  }
}

struct FoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    FoodFormView()
      .environmentObject(IBSData())
  }
}
