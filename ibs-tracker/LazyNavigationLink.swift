//
//  LazyNavigationLink.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 11/3/21.
//

import SwiftUI

public struct LazyNavigationLink<Label, Destination> : View where Label : View, Destination : View {
  private var destination: Destination
  private var label: () -> Label

  public init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
    self.destination = destination
    self.label = label
  }

  public var body: some View {
    NavigationLink(destination: LazyView(destination), label: label)
  }
}
