//
//  SwiftUIActivityViewController.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

extension UIKitBridge {
  struct SwiftUIActivityViewController: UIViewControllerRepresentable {
    let activityViewController = ActivityViewController()

    func makeUIViewController(context: Context) -> ActivityViewController {
      activityViewController
    }

    func updateUIViewController(_ uiViewController: ActivityViewController, context: Context) {
      //
    }

    func share(any data: Any) {
      activityViewController.share(data)
    }
  }

  class ActivityViewController: UIViewController {
    var data: Any!

    @objc func share(_ data: Any) {
      self.data = data
      let vc = UIActivityViewController(activityItems: [data], applicationActivities: [])
      vc.excludedActivityTypes = []
      present(vc, animated: true, completion: nil)
      vc.popoverPresentationController?.sourceView = view
    }
  }
}
