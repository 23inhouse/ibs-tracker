//
//  TypeShape.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 16/1/21.
//

import SwiftUI
import PureSwiftUI

private let strokeStyle = StrokeStyle(lineWidth: 5, lineJoin: .round)

struct TypeShape: Shape {
  var type: ItemType

  func type(for type: ItemType) -> Pathable {
    switch type {
    case .ache: return AcheShape()
    case .bm: return BowelMovementShape()
    case .food: return FoodShape()
    case .gut: return GutShape()
    case .medication: return MedicationShape()
    case .mood: return MoodShape()
    case .note: return NoteShape()
    case .skin: return SkinShape()
    case .weight: return WeightShape()
    default: return BowelMovementShape()
    }
  }

  func path(in rect: CGRect) -> Path {
    return type(for: type).path(in: rect)
  }
}

struct TypeShape_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TypeShape(type: .ache)
        .stroke(style: strokeStyle)
      TypeShape(type: .bm)
        .stroke(style: strokeStyle)
      TypeShape(type: .food)
        .stroke(style: strokeStyle)
      TypeShape(type: .gut)
        .stroke(style: strokeStyle)
      TypeShape(type: .medication)
        .stroke(style: strokeStyle)
      TypeShape(type: .mood)
        .stroke(style: strokeStyle)
      TypeShape(type: .note)
        .stroke(style: strokeStyle)
      TypeShape(type: .skin)
        .stroke(style: strokeStyle)
      TypeShape(type: .weight)
        .stroke(style: strokeStyle)
    }
    .frame(200, 200)
    .previewSizeThatFits()
    .padding(40)
    .showLayoutGuides(true)
  }
}
