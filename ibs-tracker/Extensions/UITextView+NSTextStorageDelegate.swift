//
//  UITextView+NSTextStorageDelegate.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import UIKit

extension UITextView: NSTextStorageDelegate {
  public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorage.EditActions, range editedRange: NSRange, changeInLength delta: Int) {
    placeholderLabel.isHidden = !text.isEmpty
  }
}
