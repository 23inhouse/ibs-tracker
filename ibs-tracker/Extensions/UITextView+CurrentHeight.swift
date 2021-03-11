//
//  UITextView+CurrentHeight.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import UIKit

extension UITextView {
  func currentHeight() -> CGFloat {
    let size = sizeThatFits(CGSize(frame.width, CGFloat.greatestFiniteMagnitude))
    return size.height
  }
}
