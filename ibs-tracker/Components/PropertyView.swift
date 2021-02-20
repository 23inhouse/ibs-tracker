//
//  PropertyView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 19/1/21.
//

import SwiftUI

struct PropertyView: View {
  let text: String?
  let scale: Int
  let color: Color?

  var body: some View {
    HStack {
      Text(text ?? "")
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .truncationMode(.middle)
        .allowsTightening(true)
        .font(.caption)
        .foregroundColor(.secondary)
      Image(systemName: "\(scale).circle")
        .resizedToFit()
        .foregroundColor(color)
        .frame(15)
    }
    .frame(maxWidth: .infinity)
  }
}

struct PropertyView_Previews: PreviewProvider {
  static var previews: some View {
    PropertyView(text: "High", scale: 4, color: .purple)
  }
}
