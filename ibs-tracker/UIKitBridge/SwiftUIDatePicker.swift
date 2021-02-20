//
//  SwiftUIDatePicker.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 12/2/21.
//

import SwiftUI

extension UIKitBridge {
  struct SwiftUIDatePicker: UIViewRepresentable {
    @Binding private var selection: Date?

    private let range: ClosedRange<Date>?

    private var minimumDate: Date? { range?.lowerBound }
    private var maximumDate: Date? { range?.upperBound }

    private var minuteInterval: Int

    private let datePicker = UIDatePicker()

    init(selection: Binding<Date?>, range: ClosedRange<Date>? = nil, minuteInterval: Int = 5) {
      self._selection = selection
      self.range = range
      self.minuteInterval = minuteInterval
    }

    func makeUIView(context: Context) -> UIDatePicker {
      datePicker.datePickerMode = .dateAndTime
      datePicker.preferredDatePickerStyle = .wheels
      datePicker.sizeToFit()
      datePicker.minuteInterval = minuteInterval
      datePicker.minimumDate = minimumDate
      datePicker.maximumDate = maximumDate
      datePicker.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .valueChanged)
      return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
      guard let selection = selection else { return }
      datePicker.date = selection
    }

    func makeCoordinator() -> SwiftUIDatePicker.Coordinator {
      Coordinator(selection: $selection, in: range, minuteInterval: minuteInterval)
    }

    class Coordinator: NSObject {
      private let selection: Binding<Date?>
      private let range: ClosedRange<Date>?
      private let minuteInterval: Int

      init(selection: Binding<Date?>, in range: ClosedRange<Date>? = nil, minuteInterval: Int = 5) {
        self.selection = selection
        self.range = range
        self.minuteInterval = minuteInterval
      }

      @objc func changed(_ sender: UIDatePicker) {
        self.selection.wrappedValue = sender.date
      }
    }
  }
}
