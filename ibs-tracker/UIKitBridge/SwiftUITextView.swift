//
//  SwiftUITextView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 28/3/21.
//

import SwiftUI

extension UIKitBridge {
  struct SwiftUITextView: UIViewRepresentable {
    @Binding var text: String

    private let isFirstResponder: Bool
    private let onEditingChanged: ((_ focused: Bool) -> Void)
    private let onCommit: (() -> Void)

    private var title: String

    init(_ title: String, text: Binding<String>, isFirstResponder: Bool = false, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
      self.title = title
      self._text = text
      self.isFirstResponder = isFirstResponder
      self.onEditingChanged = onEditingChanged
      self.onCommit = onCommit
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<SwiftUITextView>) -> UITextView {
      let textView = UITextView()
      textView.font = UIFont.preferredFont(forTextStyle: .body)
      textView.backgroundColor = .clear
      textView.delegate = context.coordinator
      textView.textContainerInset = .zero
      textView.textContainer.lineFragmentPadding = 0
      textView.returnKeyType = .done
      textView.text = title
      textView.placeholder = title

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        textView.text = text
      }
      return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<SwiftUITextView>) {
      uiView.placeholder = title
      uiView.text = text

      guard isFirstResponder else { return }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if uiView.window != nil, !uiView.isFirstResponder {
          uiView.becomeFirstResponder()
        }
      }
    }

    class Coordinator: NSObject, UITextViewDelegate {
      var parent: SwiftUITextView

      init(_ autoFocusTextView: SwiftUITextView) {
        self.parent = autoFocusTextView
      }

      func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
          textView.resignFirstResponder()
          parent.onCommit()
          return false
        }
        return true
      }

      func textViewDidChangeSelection(_ textView: UITextView) {
        parent.text = textView.text ?? ""
      }

      func textViewDidEndEditing(_ textView: UITextView) {
        parent.onEditingChanged(false)
      }

      func textViewDidBeginEditing(_ textView: UITextView) {
        parent.onEditingChanged(true)
      }

      func textViewShouldReturn(_ textView: UITextView) -> Bool {
        parent.onCommit()
        return true
      }
    }
  }
}
