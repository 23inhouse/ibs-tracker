//
//  SaveButtonSection.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct SaveButtonSection: View {
  @Environment(\.presentationMode) private var presentation
  @EnvironmentObject private var appState: IBSData

  var name: String
  var record: IBSRecord?
  var savable: Bool = true
  var editMode: Bool = false
  var editTimestamp: Date?
  var scroller: ScrollViewProxy? = nil

  private var label: String {
    editMode ? "Update \(name)" : "Add \(name)"
  }

  var body: some View {
    Section {
      Button(action: {
        insertOrUpdate {
          DispatchQueue.main.async {
            appState.tabSelection = .day
            guard let timestamp = record?.timestamp else { return }
            appState.activeDate = IBSData.currentDate(for: timestamp)
          }
          presentation.dismiss(animation: .none)
        }
      }) {
        Text(label)
          .frame(maxWidth: .infinity)
      }
    }
    .scrollID(.saveButton)
    .modifierIf(savable) {
      $0
        .listRowBackground(Color.blue)
        .foregroundColor(.white)
    }
    .modifierIf(!savable) {
      $0
        .listRowBackground(Color.secondary.opacity(0.5))
        .foregroundColor(.white)
        .opacity(0.5)
    }
    .disabled(!savable)

    VStack(alignment: .center) {
      VStack(alignment: .center) {
        AppIconButton(angle: .degrees(0), scale: 1.8)
          .opacity(0.1)
          .scaledToFit()
          .onTapGesture {
            guard scroller != nil else { return }
            withAnimation {
              scroller!.scrollTo(id: .saveButton, anchor: .bottom)
            }
          }
      }
      .frame(maxWidth: 150)
    }
    .frame(maxWidth: .infinity)
    .frame(height: UIScreen.mainHeight * 0.666, alignment: .bottom)
  }

  private func insertOrUpdate(completionHandler: @escaping () -> Void) {
    completionHandler()

    DispatchQueue.global(qos: .userInteractive).async {
      do {
        guard let record = record else { return }

        if let editTimestamp = editTimestamp {
          try record.updateSQL(into: AppDB.current, timestamp: editTimestamp)
        } else {
          try record.insertSQL(into: AppDB.current)
        }
        DispatchQueue.main.async {
          withAnimation { appState.reloadRecordsFromSQL() }
        }
      } catch {
        print("Error: \(error)")
      }
    }
  }
}

struct SaveButtonSection_Previews: PreviewProvider {
  static var previews: some View {
    Form {
      SaveButtonSection(name: "Meal")
        .environmentObject(IBSData())
      SaveButtonSection(name: "Meal", savable: false)
        .environmentObject(IBSData())
    }
  }
}
