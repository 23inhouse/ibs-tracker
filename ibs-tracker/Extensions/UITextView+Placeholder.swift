//
//  UITextView+Placeholder.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import UIKit

extension UITextView {
  class PlaceholderLabel: UILabel {
    fileprivate func reframe(to parent: UITextView) {
      let lineFragmentPadding = parent.textContainer.lineFragmentPadding
      let width = parent.frame.width - lineFragmentPadding * 2
      let height = parent.currentHeight()
      frame.size = CGSize(width, height)
      frame.origin = CGPoint(x: lineFragmentPadding, y: parent.textContainerInset.top)
    }
  }

  var placeholderLabel: PlaceholderLabel {
    if let label = firstPlaceholder(for: subviews) {
      return label
    } else {
      let label = PlaceholderLabel(frame: .zero)
      label.font = font
      label.textColor = UIColor.placeholderText
      addSubview(label)
      return label
    }
  }

  @IBInspectable
  var placeholder: String {
    get {
      return firstPlaceholder(for: subviews)?.text ?? ""
    }
    set {
      let placeholderLabel = self.placeholderLabel
      placeholderLabel.text = newValue
      placeholderLabel.numberOfLines = 0
      placeholderLabel.reframe(to: self)

      placeholderLabel.isHidden = !text.isEmpty
      textStorage.delegate = self
    }
  }

  private func firstPlaceholder(for uiviews: [UIView]) -> PlaceholderLabel? {
    uiviews.compactMap({ $0 as? PlaceholderLabel }).first
  }
}
