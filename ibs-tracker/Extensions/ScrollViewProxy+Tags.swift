//
//  ScrollViewProxy+Tags.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

extension ScrollViewProxy {
  static func tagAnchor() -> Int { 99999 }

  func scrollTo(id: Int, anchor: UnitPoint? = .top) -> Void {
    DispatchQueue.main.async {
      scrollTo(id, anchor: anchor)
    }
  }

  func scrollToTags() -> Void {
    DispatchQueue.main.async {
      scrollTo(ScrollViewProxy.tagAnchor(), anchor: .top)
    }
  }
}
