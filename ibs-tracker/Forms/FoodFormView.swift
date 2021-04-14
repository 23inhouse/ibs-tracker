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
  @State private var speed: Scales = .none
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

  init(for foodRecord: FoodRecord? = nil) {
    guard let record = foodRecord else { return }
    self.editableRecord = record
    let vm = FormViewModel(timestamp: record.timestamp, tags: record.tags)
    self._viewModel = StateObject(wrappedValue: vm)
    self._name = State(initialValue: record.text ?? "")
    self._speed = State(initialValue: record.speed ?? .none)
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
    return IBSRecord(food: name, timestamp: timestamp.nearest(5, .minute), tags: viewModel.tags, risk: risk, size: size, speed: speed, medicinal: medicinal)
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
          .onTapGesture { scroller.scrollTo(id: .tags) }

        TagTextFieldSection(viewModel, showAllTags: $showAllTags, suggestedTags: $suggestedTags, isFirstResponder: $tagIsFirstResponder, onEditingChanged: editTags, scroller: scroller)
      }
      .scrollID(.tags)
      .scrollID(.info)

      Section {
        ScaleSlider($speed, "Speed", descriptions: Scales.foodSpeedDescriptions)
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
      calcSuggestedTags()
    }
    .onChange(of: [viewModel.tags]) { _ in
      calcSuggestedTags()
    }
    .onChange(of: [viewModel.newTag]) { _ in
      calcSuggestedTags(delay: 0.333)
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

  private func calcSuggestedTags(delay: Double = 0) {
    guard showAllTags || (!isEditingName && name.isNotEmpty) || viewModel.newTag.isNotEmpty else {
      suggestedTags = []
      return
    }

    tagFilterWorkItem?.cancel()

    let currentWorkItem = DispatchWorkItem {
      let tagsFromName = name
        .split(separator: " ")
        .filter { $0.count > 2 }
        .map { String($0).capitalizeFirstLetter() }
      let newTag = viewModel.newTag.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
      suggestedTags = Array(Set(tagsFromName + appState.tags(for: .food))).sorted(by: tagSorting(tagsFromName.map { $0.lowercased() }))
        .filter {
          let availableTag = $0.lowercased()
          return
            !viewModel.tags.contains($0) &&
            (
              showAllTags ||
                availableTag.contains(newTag) ||
                (
                  viewModel.newTag.isEmpty &&
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

  private func tagSorting(_ tagsFromName: [String]) -> (String, String) -> Bool {
    return { (lhs: String, rhs: String) -> Bool in
      var lhsI: Int = .max
      var rhsI: Int = .max
      let lhsL = lhs.lowercased()
      let rhsL = rhs.lowercased()
      for (i, word) in tagsFromName.enumerated().reversed() {
        if (lhsL.contains(word.lowercased()) || word.contains(lhsL)) {
          lhsI = i
        }
        if (rhsL.contains(word) || word.contains(rhsL)) {
          rhsI = i
        }
      }

      if lhsI < rhsI {
        return true
      } else if rhsI < lhsI {
        return false
      } else {
        return lhsL < rhsL
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
