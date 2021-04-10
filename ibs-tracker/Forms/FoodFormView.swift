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
  @State private var isEditingTags: Bool = false
  @State private var tagIsFirstResponder: Bool = false

  @State private var showAllTags: Bool = false
  @State private var suggestedTags: [String] = []
  @State private var tagFilterWorkItem: DispatchWorkItem?



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

  private var savable: Bool {
    viewModel.isValidTimestamp &&
      name.isNotEmpty && viewModel.tags.isNotEmpty
  }

  var body: some View {
    FormView("Meal", viewModel: viewModel, editableRecord: editableRecord) { scroller in
      if recentFoods.isNotEmpty {
        recentFoodSection
      }

      Section {
        UIKitBridge.SwiftUITextFieldView("Meal name. e.g. Pizza", text: $name, onEditingChanged: editName, onCommit: commitName)
          .onTapGesture {
            viewModel.scrollToTags(scroller: scroller)
          }

        TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, isFirstResponder: $tagIsFirstResponder, onEditingChanged: editTags, scroller: scroller)
      }
      .id(ScrollViewProxy.tagAnchor())

      Section {
        ScaleSlider($size, "Size", descriptions: FoodSizes.descriptions)
        ScaleSlider($risk, "Risk", descriptions: Scales.foodRiskDescriptions)
        Toggle("Medicinal", isOn: $medicinal)
      }

      SaveButtonSection(name: "Meal", record: record, savable: savable, editMode: editMode, editTimestamp: editableRecord?.timestamp, scroller: scroller)
    }
    .onAppear {
      calcRecentFoods()
      calcSuggestedTags()
    }
    .onChange(of: [showAllTags, isEditingName, isEditingTags]) { _ in
      calcSuggestedTags(delay: 0)
    }
    .onChange(of: [viewModel.tags]) { _ in
      calcSuggestedTags(delay: 0)
    }
    .onChange(of: [viewModel.newTag]) { _ in
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
    name = name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func editName(_ isEditing: Bool) {
    isEditingName = isEditing
  }

  private func editTags(_ isEditing: Bool) {
    if isEditing && !isEditingTags {
      name = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    isEditingTags = isEditing
    tagIsFirstResponder = false
    viewModel.showTagSuggestions(isEditing)
  }

  private func calcRecentFoods() {
    DispatchQueue.main.async {
      recentFoods = appState.recentRecords(of: .food)
    }
  }

  private func calcSuggestedTags(delay: Double = 0.333) {
    guard showAllTags || (!isEditingName && name.isNotEmpty) else {
      suggestedTags = []
      return
    }

    tagFilterWorkItem?.cancel()

    let currentWorkItem = DispatchWorkItem {
      let tagsFromName = name
        .split(separator: " ")
        .filter { $0.count > 2 }
        .map { String($0) }
      suggestedTags = Array(Set(tagsFromName + appState.tags(for: .food))).sorted()
        .filter {
          let availableTag = $0.lowercased()
          return
            !viewModel.tags.contains($0) &&
            (
              showAllTags ||
                availableTag.contains(viewModel.newTag.lowercased()) ||
                (
                    tagsFromName.filter {
                      let word = String($0.lowercased())
                      return
                        viewModel.tags.filter { $0.lowercased().contains(word) }.isEmpty &&
                        (availableTag.contains(word) || word.contains(availableTag))
                    }.isNotEmpty
                )
            )
        }
    }

    tagFilterWorkItem = currentWorkItem
    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: currentWorkItem)
  }
}

struct FoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    FoodFormView()
      .environmentObject(IBSData())
  }
}
