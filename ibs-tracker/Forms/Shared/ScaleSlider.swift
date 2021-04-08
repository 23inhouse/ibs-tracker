//
//  ScaleSlider.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 1/3/21.
//

import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  typealias Value = CGSize
  static var defaultValue: Value = .zero

  static func reduce(value: inout Value, nextValue: () -> Value) {
    value = nextValue()
  }
}

struct ScaleSlider<T: Sliderable>: View {
  @State private var slider: Double = 0
  @State private var titleColor: Color = .secondary
  @State private var sliderWidth: CGFloat = 0

  @Binding private var scale: T
  private var title: String
  private var descriptions: [T: String]

  init(_ scale: Binding<T>, _ title: String, descriptions: [T: String]) {
    self._scale = scale
    self.title = title
    self.descriptions = descriptions
  }

  private let slideSize: CGFloat = 28

  private var defaultTitle: String { "\(title)" }

  private var description: String {
    guard let scale = sliderSliderable else {
      slider = -1
      return defaultTitle
    }

    guard scale.rawValue != -1 else { return defaultTitle }

    return descriptions[scale]?.capitalizeFirstLetter() ?? defaultTitle
  }

  private var sliderSliderable: T? { T(rawValue: Int(slider)) }

  var body: some View {
    VStack {
      Text(description)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(titleColor)
        .background(sizeReader)
        .onPreferenceChange(SizePreferenceKey.self, perform: widthSetter)
      ZStack(alignment: .leading) {
        Slider(value: $slider, in: -1...4, step: 0.1)
          .accentColor(titleColor)
          .onChange(of: slider, perform: { value in
            guard let scale = T(rawValue: Int(value)) else { return }
            titleColor = scale.scaleColor
          })
          .onAppear {
            slider = Double(scale.rawValue)
            titleColor = scale.scaleColor
          }
        Color.clear
          .contentShape(Rectangle())
          .frame(width: slideSize * 2, height: slideSize)
          .offset(sliderOffset, 0)
          .gesture(dragGesture)
      }
    }
  }

  private var sliderOffset: CGFloat {
    let value = CGFloat(scale.rawValue) + 1
    return value * sliderWidth / 5 - (value * (sliderWidth / slideSize / 2) + (slideSize / 2))
  }

  private var sizeReader: some View {
    GeometryReader { proxy in
      Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
    }
  }

  private var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
    DragGesture()
      .onChanged { gesture in
        let movement = gesture.location.width
        let translation = Double(round(Double(movement / sliderWidth * 5 - 1) * 10) / 10)
        guard abs(translation - slider) < 1.0 else { return }
        slider = translation
      }
      .onEnded { gesture in
        let movement = gesture.location.width
        let translation = Double(round(Double(movement / sliderWidth * 5 - 1) * 10) / 10)
        scale = T(rawValue: Int(translation))!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          slider = Double(scale.rawValue)
        }
      }
  }

  private func widthSetter(_ preferences: CGSize) {
    sliderWidth = preferences.width
  }
}

struct ScaleSlider_Previews: PreviewProvider {
  static var previews: some View {
    Form {
      Section {
        ScaleSlider(Binding.constant(.none), "Gut pain", descriptions: Scales.gutPainDescriptions)
        ScaleSlider(Binding.constant(.zero), "Bloating", descriptions: Scales.bloatingDescriptions)
        ScaleSlider(Binding.constant(.mild), "Body ache", descriptions: Scales.bodyacheDescriptions)
        ScaleSlider(Binding.constant(.moderate), "Dryness", descriptions: Scales.drynessDescriptions)
        ScaleSlider(Binding.constant(.severe), "Wetness", descriptions: Scales.wetnessDescriptions)
        ScaleSlider(Binding.constant(.extreme), "Risk", descriptions: Scales.foodRiskDescriptions)
        ScaleSlider(Binding.constant(.large), "Meal size", descriptions: FoodSizes.descriptions)
      }
    }
  }
}
