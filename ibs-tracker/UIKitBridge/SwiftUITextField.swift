//
//  SwiftUITextField.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 23/2/21.
//

import SwiftUI

extension UIKitBridge {
  struct SwiftUITextField: UIViewRepresentable {
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

    func makeUIView(context: UIViewRepresentableContext<SwiftUITextField>) -> UITextField {
      let textField = UITextField(frame: .zero)
      textField.delegate = context.coordinator
      textField.placeholder = title
      return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<SwiftUITextField>) {
      uiView.placeholder = title
      uiView.text = text

      guard isFirstResponder else { return }

      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if uiView.window != nil, !uiView.isFirstResponder {
          uiView.becomeFirstResponder()
        }
      }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
      var parent: SwiftUITextField

      init(_ autoFocusTextField: SwiftUITextField) {
        self.parent = autoFocusTextField
      }

      func textFieldDidChangeSelection(_ textField: UITextField) {
        parent.text = textField.text ?? ""
      }

      func textFieldDidEndEditing(_ textField: UITextField) {
        parent.onEditingChanged(false)
      }

      func textFieldDidBeginEditing(_ textField: UITextField) {
        parent.onEditingChanged(true)
      }

      func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        parent.onCommit()
        return true
      }
    }
  }
}
