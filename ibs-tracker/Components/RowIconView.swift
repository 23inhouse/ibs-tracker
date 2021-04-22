//
//  RowIconView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 18/1/21.
//

import SwiftUI

struct RowIconView: View {
  let type: ItemType
  let color: Color?
  let medicinal: Bool
  let mealType: MealType?

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  var body: some View {
    medicinalView(medicinal) {
      if mealType != nil {
        ZStack {
          typeShap
            .frame(35)
            .padding(10)
            .offset(x: 0, y: -3)
          mealName
        }
      } else if [.food, .weight, .medication].contains(type) {
        typeShap
          .frame(35)
          .padding(10)
      } else {
        typeShap
          .frame(40)
          .padding(5)
      }
    }
  }

  private var typeShap: some View {
    TypeShape(type: type)
      .stroke(style: strokeStyle)
      .foregroundColor(color)
  }

  private var mealName: some View {
    Text(mealTypeName)
      .offset(x: 0, y: 24)
      .truncationMode(.middle)
      .fontSize(9)
      .foregroundColor(color)
      .lineLimit(1)
      .layoutPriority(1)
  }

  private var mealTypeName: String {
    mealType?.rawValue.capitalized ?? "Food"
  }

  private func medicinalView<Content: View>(_ medicinal: Bool, @ViewBuilder content: @escaping () -> Content) -> some View {
    Group {
      if medicinal {
        ZStack {
          TypeShape(type: .medication)
            .stroke(style: strokeStyle)
            .foregroundColor(color)
            .frame(35)
            .padding(10)
            .offset(CGSize(width: -5, height: -5))
          content()
            .scaleEffect(0.65)
            .offset(CGSize(width: 8, height: 8))
        }
      } else {
        content()
      }
    }
  }
}

struct RowIconView_Previews: PreviewProvider {
  static let filler: some View = Color.secondary.frame(height: 60)
  static var previews: some View {
    List {
      HStack {
        RowIconView(type: .food, color: .secondary, medicinal: true, mealType: nil)
          .width(45)
        filler
      }
      HStack {
        RowIconView(type: .food, color: .green, medicinal: false, mealType: .breakfast)
          .width(45)
        filler
      }
      HStack {
        RowIconView(type: .food, color: .orange, medicinal: false, mealType: .lunch)
          .width(45)
        filler
      }
      HStack {
        RowIconView(type: .note, color: .secondary, medicinal: false, mealType: nil)
          .width(45)
        filler
      }
    }
  }
}
