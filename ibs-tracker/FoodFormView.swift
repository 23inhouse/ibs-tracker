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
  @State private var timestamp: Date? {
    didSet {
      isValidTimestamp = isValid(timestamp: timestamp)
    }
  }
  @State private var size: FoodSizes = .none
  @State private var risk: Scales = .none
  @State private var tags = [String]()
  @State private var newTag = ""
  @State private var recentFoodSelection: IBSRecord?
  @State private var showAlert: Bool = false
  @State private var isValidTimestamp: Bool = true

  init(for foodRecord: FoodRecord? = nil) {
    self.foodRecord = foodRecord
    guard let record = foodRecord else { return }
    self._name = State(initialValue: record.text ?? "")
    self._timestamp = State(initialValue: record.timestamp)
    self._size = State(initialValue: record.size ?? .none)
    self._risk = State(initialValue: record.risk ?? .none)
    self._tags = State(initialValue: record.tags)
  }

  private var foodRecord: FoodRecord? = nil

  private var tagList: [String] { tags }

  private var editMode: Bool {
    get { foodRecord != nil }
  }

  private var ingredientPlaceholder: String {
    tags.isEmpty ? "Add ingredient" : "Add another ingredient"
  }

  private var recentFoodPlaceholder: String {
    name.isEmpty && tags.isEmpty ? "Choose from recent meals" : "Replace with recent meal"
  }

  private var recentFoods: [IBSRecord] {
    appState.recentRecords(of: .food)
  }

  var body: some View {
    Form {
      if recentFoods.isNotEmpty {
        recentFoodSection
      }

      Section {
        TextField("Meal name. e.g. Pizza", text: $name)

        if tags.isNotEmpty {
          Text("Ingredients")
            .foregroundColor(.secondary)
        }

        List { listItems }
        TextField(ingredientPlaceholder, text: $newTag, onCommit: addNewTag)
      }

      Section {
        sizePicker
        riskPicker
      }

      if name.isNotEmpty && tags.isNotEmpty {
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
        Text(editMode ? "Update meal" : "Add meal")
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

  private var listItems: some View {
    ForEach(tags.indices, id: \.self) { i in
      if tagList.indices.contains(i) {
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

  private func delete(completionHandler: () -> Void) {
    completionHandler()

    DispatchQueue.global(qos: .utility).async {
      do {
        guard let record = foodRecord as? IBSRecord else { return }
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
        let record = IBSRecord(food: name, timestamp: timestamp.nearest(5, .minute), tags: tags, risk: risk, size: size)

        if let foodRecord = foodRecord {
          try record.updateSQL(into: AppDB.current, timestamp: foodRecord.timestamp)
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
}

struct FoodFormView_Previews: PreviewProvider {
  static var previews: some View {
    FoodFormView()
      .environmentObject(IBSData())
  }
}
