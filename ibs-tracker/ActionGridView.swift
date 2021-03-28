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
        Spacer()
        PaddedHStack {
          ActionNavigationLink(type: .note, text: "Notes") { NoteFormView() }
          ActionNavigationLink(type: .medication, text: "medicaiton") { MedicationFormView() }
          ActionNavigationLink(type: .food, text: "Food") { FoodFormView() }
        }

        PaddedHStack {
          ActionNavigationLink(type: .mood, text: "Mood\nStress") { MoodFormView() }
          ActionNavigationLink(type: .ache, text: "Headache\nBody ache") { AcheFormView() }
          ActionNavigationLink(type: .gut, text: "Bloating\nPain") { GutFormView() }
        }

        PaddedHStack {
          ActionNavigationLink(type: .skin, text: "Skin") { SkinFormView() }
          ActionNavigationLink(type: .weight, text: "Weight") { WeightFormView() }
          ActionNavigationLink(type: .bm, text: "Poop") { BMFormView() }
        }
      }
      .padding(.bottom, 20)
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
