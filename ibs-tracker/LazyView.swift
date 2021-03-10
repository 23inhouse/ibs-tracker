//
//  LazyView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 10/3/21.
//

import SwiftUI

public struct LazyView<Content: View>: View {
  private let content: () -> Content

  public init(_ content: @autoclosure @escaping () -> Content) {
    self.content = content
  }

  public var body: Content {
    content()
  }
}
