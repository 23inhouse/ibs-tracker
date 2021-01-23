//
//  IBSItemView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 1.6, lineJoin: .round)

struct IBSItemView: View {
  var shape: TypeShape
  var text: String

  var body: some View {
    VStack {
      shape
        .stroke(style: strokeStyle)
        .frame(30)
        .padding(.all, 5)
      Text(text)
        .font(.title3)
    }
    .padding(5)
    .frame(maxWidth: .infinity)
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(Color.secondary, lineWidth: 1.2)
    )
    .padding(.all, 5)
  }
}

struct IbsItemView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      HStack {
        IBSItemView(shape: TypeShape(type: .ache), text: "Pain/Ache")
        IBSItemView(shape: TypeShape(type: .bm), text: "BMs")
        IBSItemView(shape: TypeShape(type: .food), text: "Food")
      }
      HStack {
        IBSItemView(shape: TypeShape(type: .gut), text: "Symptoms")
        IBSItemView(shape: TypeShape(type: .medication), text: "Medication")
        IBSItemView(shape: TypeShape(type: .mood), text: "Mood")
      }
      HStack {
        IBSItemView(shape: TypeShape(type: .note), text: "Note")
        IBSItemView(shape: TypeShape(type: .weight), text: "Weight")
      }
    }
  }
}
