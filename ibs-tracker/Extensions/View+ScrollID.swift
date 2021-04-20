//
//  View+ScrollID.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 13/4/21.
//

import SwiftUI

enum ScrollID {
  case condition
  case gridContent
  case info
  case medication
  case note
  case saveButton
  case tags
}

extension View {
  func scrollID(_ namedID: ScrollID) -> some View {
    id(namedID)
  }
}