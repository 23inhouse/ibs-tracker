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

  private var defaultTitle: String { "\(title)" }

  private var description: String {
    guard let scale = sliderSliderable else {
      slider = -1
      return defaultTitle
    }

    return descriptions[scale]?.capitalizeFirstLetter() ?? defaultTitle
  }

  private var sliderSliderable: T? { T(rawValue: Int(slider)) }

  var body: some View {
    VStack {
      ZStack {
        Text(description)
          .frame(maxWidth: .infinity, alignment: .leading)
          .foregroundColor(titleColor)
          .background(
            GeometryReader { proxy in
              Color.clear.preference(key: SizePreferenceKey.self, value: proxy.size)
            }
          )
      }
      .onPreferenceChange(SizePreferenceKey.self) { preferences in
        sliderWidth = preferences.width
      }
      Slider(value: $slider, in: -1...4, step: 0.1)
        .accentColor(titleColor)
        .gesture(
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
            }
        )
        .onChange(of: slider, perform: { value in
          guard let scale = T(rawValue: Int(value)) else { return }
          titleColor = scale.scaleColor
        })
        .onAppear {
          slider = Double(scale.rawValue)
          titleColor = scale.scaleColor
        }
    }
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
