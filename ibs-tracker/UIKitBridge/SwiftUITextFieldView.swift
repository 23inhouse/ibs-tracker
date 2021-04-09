//
//  SwiftUITextFieldView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/3/21.
//

import SwiftUI

extension UIKitBridge {
  struct SwiftUITextFieldView: View {
    @State var height: CGFloat = 0
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

    var body: some View {
      SwiftUITextFieldViewInner(title, text: $text, height: $height, isFirstResponder: isFirstResponder, onEditingChanged: onEditingChanged, onCommit: onCommit)
        .frame(height: height)
    }
  }

  private struct SwiftUITextFieldViewInner: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat

    private let isFirstResponder: Bool
    private let onEditingChanged: ((_ focused: Bool) -> Void)
    private let onCommit: (() -> Void)

    private var title: String

    init(_ title: String, text: Binding<String>, height: Binding<CGFloat>, isFirstResponder: Bool = false, onEditingChanged: @escaping (Bool) -> Void = { _ in }, onCommit: @escaping () -> Void = {}) {
      self.title = title
      self._text = text
      self._height = height
      self.isFirstResponder = isFirstResponder
      self.onEditingChanged = onEditingChanged
      self.onCommit = onCommit
    }

    func makeCoordinator() -> Coordinator {
      Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<SwiftUITextFieldViewInner>) -> UITextView {
      let textView = UITextView()
      textView.font = UIFont.preferredFont(forTextStyle: .body)
      textView.backgroundColor = .clear
      textView.delegate = context.coordinator
      textView.textContainerInset = .zero
      textView.textContainer.lineFragmentPadding = 0
      textView.returnKeyType = .done
      textView.text = text
      textView.placeholder = title
      return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<SwiftUITextFieldViewInner>) {
      uiView.placeholder = title
      uiView.text = text
      height = uiView.currentHeight()

      guard isFirstResponder else { return }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if uiView.window != nil, !uiView.isFirstResponder {
          uiView.becomeFirstResponder()
        }
      }
    }

    class Coordinator: NSObject, UITextViewDelegate {
      var parent: SwiftUITextFieldViewInner

      init(_ autoFocusTextView: SwiftUITextFieldViewInner) {
        self.parent = autoFocusTextView
      }

      func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
          parent.onCommit()
          return false
        }
        return true
      }

      func textViewDidChangeSelection(_ textView: UITextView) {
        parent.text = textView.text ?? ""
        parent.height = textView.currentHeight()
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
