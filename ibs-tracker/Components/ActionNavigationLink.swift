//
//  ActionNavigationLink.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 26/2/21.
//

import SwiftUI

struct ActionNavigationLink<Destination: View>: View {
  private let destination: Destination
  private let type: ItemType
  private let text: String

  init(type: ItemType, text: String, @ViewBuilder destination: @escaping () -> Destination) {
    self.destination = destination()
    self.type = type
    self.text = text
  }

  var body: some View {
    NavigationLink(destination: destination) {
      IBSItemView(shape: TypeShape(type: type), text: text)
    }
  }
}

struct ActionNavigationLink_Previews: PreviewProvider {
  static var previews: some View {
    ActionNavigationLink(type: .food, text: "Food") {
      FoodFormView()
    }
  }
}
