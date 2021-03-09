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
      VStack {
        HStack {
          ActionNavigationLink(type: .weight, text: "Weight") { WeightFormView() }
          ActionNavigationLink(type: .note, text: "Notes") { NoteFormView() }
        }
        .padding(.leading)
        .padding(.trailing)

        HStack {
          IBSItemView(shape: TypeShape(type: .mood), text: "Mood/stress")
          ActionNavigationLink(type: .medication, text: "medicaiton") { MedicationFormView() }
        }
        .padding(.leading)
        .padding(.trailing)

        HStack {
          ActionNavigationLink(type: .gut, text: "Bloating/pain") { GutFormView() }
          IBSItemView(shape: TypeShape(type: .ache), text: "Pain/aches")
        }
        .padding(.leading)
        .padding(.trailing)

        HStack {
          ActionNavigationLink(type: .food, text: "Food") { FoodFormView() }
          ActionNavigationLink(type: .bm, text: "Poop") { BMFormView() }
        }
        .padding(.leading)
        .padding(.trailing)
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
