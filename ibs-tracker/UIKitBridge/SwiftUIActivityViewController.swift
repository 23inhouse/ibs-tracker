//
//  SwiftUIActivityViewController.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

extension UIKitBridge {
  struct SwiftUIActivityViewController: UIViewControllerRepresentable {
    @Binding var activityItems: [Any]

    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<UIKitBridge.SwiftUIActivityViewController>) -> UIActivityViewController {
      UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<UIKitBridge.SwiftUIActivityViewController>) {}
  }
}
