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
        .frame(40)
      Text(text)
        .font(Font.footnote.leading(.tight))
        .lineLimit(2)
        .multilineTextAlignment(.center)
    }
    .padding(5)
    .frame(minWidth: 80, idealWidth: 100, maxWidth: .infinity, minHeight: 80, idealHeight: 100, maxHeight: 100, alignment: .center)
    .aspectRatio(1.0, contentMode: .fit)
    .overlay(
      RoundedRectangle(cornerRadius: 15)
        .stroke(Color.secondary, lineWidth: 1.2)
    )
    .padding(5)
  }
}

struct IbsItemView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      HStack {
        IBSItemView(shape: TypeShape(type: .ache), text: "Pain\nAche")
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
