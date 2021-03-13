//
//  SwiftUIPDFView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 13/3/21.
//

import PDFKit
import SwiftUI

extension UIKitBridge {
  struct SwiftUIPDFView: UIViewRepresentable {
    let url: URL?

    init(_ url: URL?) {
      self.url = url
    }

    func makeUIView(context: Context) -> some UIView {
      let pdfView = PDFView()
      pdfView.autoScales = true
      if let url = url {
        pdfView.document = PDFDocument(url: url)
      } else {
        print("Error: no PDF url")
      }
      return pdfView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
      // Update the view.
    }
  }
}
