//
//  PDF.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 13/3/21.
//

import Foundation
import PDFKit
import SwiftUI

struct PDF {
  let recordsByDay: [DayRecord]
  let includeFood: Bool

  static let pageA4width = 595
  static let pageA4height = 842
  static let pageA4 = CGRect(x: 0, y: 0, width: pageA4width, height: pageA4height)
  static let metaData = [
      kCGPDFContextTitle: "IBS Report",
      kCGPDFContextAuthor: "IBS tracker"
    ]
}

extension PDF {
  static func encode(_ pdf: PDF) throws -> Data {
    let format = UIGraphicsPDFRendererFormat()
    format.documentInfo = metaData as [String: Any]

    let renderer = UIGraphicsPDFRenderer(bounds: pageA4, format: format)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .left

    let headerStyle = [
      NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
      NSAttributedString.Key.backgroundColor: UIColor.lightGray,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    let timeStyle = [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10),
      NSAttributedString.Key.foregroundColor: UIColor.black,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    let tagStyle = [
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9),
      NSAttributedString.Key.foregroundColor: UIColor.lightGray,
      NSAttributedString.Key.paragraphStyle: paragraphStyle
    ]

    func drawRect(x: Int, y: Int, width: Int, height: Int, fillColor: CGColor) {
      let backgroundRect = CGRect(x: x, y: y, width: width, height: height)
      let c = UIGraphicsGetCurrentContext()!
      c.setLineWidth(1)
      c.setFillColor(fillColor)
      c.addRect(backgroundRect)
      c.fillPath()
    }

    func contentStyle(for record: IBSRecord) -> [NSAttributedString.Key: Any] {
      let fontColor = UIColor(pdf.color(for: record))
      let fontSize: CGFloat = 10
      let font = record.type == .weight
        ? UIFont.boldSystemFont(ofSize: fontSize)
        : UIFont.systemFont(ofSize: fontSize)

      return [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: fontColor,
        NSAttributedString.Key.paragraphStyle: paragraphStyle,
      ]
    }

    let padding = 10
    let height: Int = 15
    let vSpacer: Int = 5

    func space(for lines: Int) -> Int {
      (lines * height) + (lines * vSpacer) - vSpacer
    }

    return renderer.pdfData { context in
      context.beginPage()

      var yPos: Int = 0 + padding

      for dayRecord in pdf.recordsByDay {
        if yPos > pageA4height - ((3 * height) + (2 * vSpacer) + padding) {
          context.beginPage()
          yPos = 0 + padding
        }

        let reportedRecords = dayRecord.records.filter {
          guard !pdf.includeFood else { return true }

          let type = $0.medicinal ?? false ? .medication : $0.type
          if type == .food {
            if pdf.color(for: $0) != Color.black { return true }
            if $0.risk != nil || $0.size != nil { return true }
            return false
          }

          return true
        }

        let width = pageA4width - (2 * padding)
        let fillColor = UIColor.lightGray.cgColor
        drawRect(x: 0 + padding, y: yPos, width: width, height: height, fillColor: fillColor)

        let dateText = dayRecord.date.string(for: "dd MMM YYYY")
        let dateRect = CGRect(x: 0 + padding + 3, y: yPos + 2, width: pageA4width - (2 * padding), height: height)
        dateText.draw(in: dateRect, withAttributes: headerStyle)

        yPos += height + vSpacer

        for record in reportedRecords {
          if yPos > pageA4height - space(for: 2) {
            context.beginPage()
            yPos = 0 + padding
          }

          let (xPos, width) = pdf.column(for: record)

          guard width > 0 else { continue }

          let timeText = record.timestamp.string(for: "hh:mm a")
          let timeRect = CGRect(x: 15, y: yPos, width: 50, height: height)
          timeText.draw(in: timeRect, withAttributes: timeStyle)

          let nameText = pdf.content(for: record)
          let nameRect = CGRect(x: xPos, y: yPos, width: width, height: height)
          nameText.draw(in: nameRect, withAttributes: contentStyle(for: record))

          let tagText = record.tags.joined(separator: ", ")
          let tagRect = CGRect(x: xPos, y: yPos + height, width: width, height: height)
          tagText.draw(in: tagRect, withAttributes: tagStyle)

          yPos += height + height + vSpacer
        }
      }
    }
  }
}

private extension PDF {
  func color(for record: IBSRecord) -> Color {
    switch(record.type) {
    case .food:
      return ColorCodedContent.foodColor(for: record, default: .black)
    case .mood:
      return ColorCodedContent.moodColor(for: record.moodScore(), default: .black)
    case .ache:
      return ColorCodedContent.scaleColor(for: record.acheScore(), default: .black)
    case .gut:
      return ColorCodedContent.scaleColor(for: record.gutScore(), default: .black)
    case .skin:
      return ColorCodedContent.skinConditionColor(for: record.skinScore(), default: .black)
    case .bm:
      return ColorCodedContent.bristolColor(for: record.bristolScale, default: .black)
    default:
      return .black
    }


  }

  func content(for record: IBSRecord) -> String {
    switch record.type {
    case .food:
      return (record as FoodRecord).foodDescription()
    case .medication:
      return record.text ?? ""
    case .weight:
      return (record as WeightRecord).weightDescription()
    case .mood:
      return (record as MoodRecord).moodDescription()
    case .ache:
      return (record as AcheRecord).acheDescription()
    case .gut:
      return (record as GutRecord).gutDescription()
    case .skin:
      return (record as SkinRecord).skinDescription()
    case .bm:
      return (record as BMRecord).bristolDescription()
    default:
      return ""
    }
  }

  func column(for record: IBSRecord) -> (x: Int, w: Int) {
    let medicinal = record.medicinal ?? false
    let type = medicinal ? .medication : record.type
    switch type {
    case .food:
      return (100, 585)
    case .medication:
      return (145, 585)
    case .weight:
      return (75, 124)
    case .mood:
      return (245, 419)
    case .ache:
      return (245, 419)
    case .gut:
      return (245, 419)
    case .skin:
      return (245, 419)
    case .bm:
      return (370, 585)
    default:
      return (0, 0)
    }
  }
}
