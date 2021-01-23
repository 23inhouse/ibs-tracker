//
//  ActionGridView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI

struct ActionGridView: View {
  var body: some View {
    VStack {
      Text("Add new record")
        .font(.title)
        .padding(35)
      HStack {
        IBSItemView(shape: TypeShape(type: .weight), text: "Weight")
        IBSItemView(shape: TypeShape(type: .note), text: "Notes")
      }
      .padding(.leading)
      .padding(.trailing)

      HStack {
        IBSItemView(shape: TypeShape(type: .mood), text: "Mood/stress")
        IBSItemView(shape: TypeShape(type: .medication), text: "Medication")
      }
      .padding(.leading)
      .padding(.trailing)

      HStack {
        IBSItemView(shape: TypeShape(type: .gut), text: "Bloating/pain")
        IBSItemView(shape: TypeShape(type: .ache), text: "Pain/aches")
      }
      .padding(.leading)
      .padding(.trailing)

      HStack {
        IBSItemView(shape: TypeShape(type: .food), text: "Food")
        IBSItemView(shape: TypeShape(type: .bm), text: "Stool")
      }
      .padding(.leading)
      .padding(.trailing)
    }
  }
}

struct ActionGridView_Previews: PreviewProvider {
  static var previews: some View {
    ActionGridView()
  }
}
