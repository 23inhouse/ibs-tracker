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

  private var listRowBackground: Color {
    return isValid ? .clear : Color(red: 1, green: 0, blue: 0, opacity: 0.333)
  }

  private var opacity: Double {
    return isValid ? 1.0 : 0.8
  }

  var body: some View {
    Section {
      UIKitBridge.SwiftUIDatePicker(selection: $timestamp, range: nil, minuteInterval: 5)
    }
    .listRowBackground(listRowBackground)
    .opacity(opacity)
  }
}

struct DatePickerSectionView_Previews: PreviewProvider {
  static var previews: some View {
    DatePickerSectionView(timestamp: Binding.constant(nil), isValid: Binding.constant(false))
      .environmentObject(IBSData())
  }
}
