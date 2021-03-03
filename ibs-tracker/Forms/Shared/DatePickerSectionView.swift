//
//  DatePickerSectionView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct DatePickerSectionView: View {
  @EnvironmentObject private var appState: IBSData

  @Binding var timestamp: Date?
  @Binding var isValid: Bool
  var initial: Date?

  init(timestamp: Binding<Date?>, isValid: Binding<Bool>, initial: Date?) {
    self._timestamp = timestamp
    self._isValid = isValid
    self.initial = initial
  }

  private var editMode: Bool {
    initial != nil
  }

  var body: some View {
    Section {
      UIKitBridge.SwiftUIDatePicker(selection: $timestamp, range: nil, minuteInterval: 5)
        .onChange(of: timestamp) { value in
          timestamp = value
          isValid = isValid(timestamp: value)
        }
    }
    .modifierIf(!isValid) {
      $0
        .listRowBackground(Color(red: 1, green: 0, blue: 0, opacity: 0.333))
        .opacity(0.8)
    }
    .onAppear {
      guard !editMode else { return }
      isValid = isValid(timestamp: timestamp)
    }
  }

  private func isValid(timestamp: Date?) -> Bool {
    guard let timestamp = timestamp else { return false }
    guard timestamp != initial else { return true}

    return appState.isAvailable(timestamp: timestamp)
  }
}

struct DatePickerSectionView_Previews: PreviewProvider {
  static var previews: some View {
    DatePickerSectionView(timestamp: Binding.constant(nil), isValid: Binding.constant(false), initial: nil)
      .environmentObject(IBSData())
  }
}
