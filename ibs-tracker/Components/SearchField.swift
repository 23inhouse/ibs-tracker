//
//  SearchField.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 4/4/21.
//

import SwiftUI

struct SearchField: View {
  @Environment(\.colorScheme) var colorScheme
  @Binding var search: String

  private var backgroundColor: Color { colorScheme == .dark ? .black : .white }

  var body: some View {
    TextField("Search ...", text: $search)
      .padding(5)
      .padding(.leading, 25)
      .backgroundColor(backgroundColor)
      .cornerRadius(8)

      .overlay(
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.secondary)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 5)
          if search.isNotEmpty {
            Image(systemName: "xmark.circle.fill")
              .contentShape(Rectangle())
              .foregroundColor(.secondary)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
              .padding(.trailing, 5)
              .onTapGesture {
                search = ""
              }
          }
        }
      )
  }
}

struct SearchField_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      VStack {
        Spacer()
        SearchField(search: Binding.constant(""))
        Spacer()
        Form {
          SearchField(search: Binding.constant(""))
        }
        Spacer()
      }
      .backgroundColor(.secondary)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          SearchField(search: Binding.constant("foobar"))
            .frame(width: 140)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Image(systemName: "square.and.arrow.up")
            .foregroundColor(.blue)
        }
      }
    }
  }
}
