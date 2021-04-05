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
  @State private var recentFoods: [IBSRecord] = []
  @State private var recentFoodSelection: IBSRecord?
  @State private var isEditingName: Bool = false
  @State private var nameIsCompleted: Bool = false
  @State private var tagIsFirstResponder: Bool = false

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []

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

  private var record: IBSRecord? {
    guard let timestamp = viewModel.timestamp else { return nil }
    return IBSRecord(food: name, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, risk: risk, size: size, medicinal: medicinal)
  }

  private var tagPlaceholder: String {
    viewModel.tags.isEmpty ? "Add ingredient" : "Add another ingredient"
  }

  var body: some View {
    FormView("Meal", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      Section {
        UIKitBridge.SwiftUITextFieldView("Meal name. e.g. Pizza", text: $name, onEditingChanged: editName, onCommit: commitName)
          .onTapGesture {
            viewModel.scrollToTags(scroller: scroller)
          }

        TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, isFirstResponder: $tagIsFirstResponder, scroller: scroller)
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
    .onAppear {
      calcRecentFoods()
      calcSuggestedTags()
    }
    .onChange(of: [showAllTags, isEditingName, nameIsCompleted]) { _ in
      calcSuggestedTags()
    }
    .onChange(of: [viewModel.tags, [viewModel.newTag], [name]]) { _ in
      calcSuggestedTags()
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
    tagIsFirstResponder = true
    isEditingName = false
    nameIsCompleted = true
    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5) {
      tagIsFirstResponder = false
    }
  }

  private func editName(_ isEditing: Bool) {
    isEditingName = isEditing
  }

  private func calcRecentFoods() {
    DispatchQueue.main.async {
      recentFoods = appState.recentRecords(of: .food)
    }
  }

  private func calcSuggestedTags() {
    guard showAllTags || !isEditingName else {
      suggestedTags = []
      return
    }

    DispatchQueue.main.async {
      suggestedTags = appState.tags(for: .food)
        .filter {
          let availableTag = $0.lowercased()
          return
            !viewModel.tags.contains($0) &&
            (
              showAllTags ||
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
  }
}

struct FoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    FoodFormView()
      .environmentObject(IBSData())
  }
}
