//
//  ActionGridView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI

struct ActionGridView: View {
  var body: some View {
    NavigationView {
      VStack(alignment: .center) {
        PaddedHStack {
          ActionNavigationLink(type: .food, text: "Food") { FoodFormView() }
          ActionNavigationLink(type: .medication, text: "medicaiton") { MedicationFormView() }
          ActionNavigationLink(type: .note, text: "Notes") { NoteFormView() }
        }

        PaddedHStack {
          ActionNavigationLink(type: .gut, text: "Bloating\nPain") { GutFormView() }
          ActionNavigationLink(type: .ache, text: "Headache\nBody ache") { AcheFormView() }
          ActionNavigationLink(type: .mood, text: "Mood\nStress") { MoodFormView() }
        }

        PaddedHStack {
          ActionNavigationLink(type: .mood, text: "Skin") { SkinFormView() }
          ActionNavigationLink(type: .weight, text: "Weight") { WeightFormView() }
          ActionNavigationLink(type: .bm, text: "Poop") { BMFormView() }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Add record")
        }
      }
    }
  }
}

struct ActionGridView_Previews: PreviewProvider {
  static var previews: some View {
    ActionGridView()
  }
}

struct PaddedHStack<Content: View>: View {
  private let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    HStack {
      content()
    }
    .padding(.leading)
    .padding(.trailing)
  }
}
