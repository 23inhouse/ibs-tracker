//
//  ScrollViewProxy+Tags.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 9/3/21.
//

import SwiftUI

extension ScrollViewProxy {
  func scrollTo(id: ScrollID, anchor: UnitPoint? = .top, animate isAnimated: Bool = true) -> Void {
    DispatchQueue.main.async {
      guard isAnimated else {
        scrollTo(id, anchor: anchor)
        return
      }
      withAnimation {
        scrollTo(id, anchor: anchor)
      }
    }
  }
}
