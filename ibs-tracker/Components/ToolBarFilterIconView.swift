//
//  ToolBarFilterIconView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/1/21.
//

import SwiftUI

struct ToolBarFilterIconView: View {
  private var type: ItemType
  @Binding var activeFilter: ItemType?

  init(for type: ItemType, filteredBy activeFilter: Binding<ItemType?>) {
    self.type = type
    self._activeFilter = activeFilter
  }

  private let strokeStyle = StrokeStyle(lineWidth: 1.5, lineJoin: .round)

  var body: some View {
    TypeShape(type: type)
      .stroke(style: strokeStyle)
      .foregroundColor(activeFilter == type ? .blue : .secondary)
      .frame(25)
      .padding(5)
  }
}

struct SearchNavigationFilterIcon_Previews: PreviewProvider {
  @State static var filter: ItemType? = .food

  static var previews: some View {
    ToolBarFilterIconView(for: .food, filteredBy: $filter)
  }
}
