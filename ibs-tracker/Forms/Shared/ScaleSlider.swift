//
//  ScaleSlider.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 1/3/21.
//

import SwiftUI

struct ScaleSlider<T: Sliderable>: View {
  @State private var slider: Double = 0
  @State private var titleColor: Color = .secondary

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
      $slider.wrappedValue = -1
      return defaultTitle
    }
    return descriptions[scale]?.capitalizeFirstLetter() ?? defaultTitle
  }

  private var sliderSliderable: T? { T(rawValue: Int(slider)) }


  var body: some View {
    VStack {
      Text(description)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(titleColor)
      Slider(value: $slider, in: -1...4, step: 0.1)
        .onChange(of: slider, perform: { value in
          let scale = T(rawValue: Int(value))!
          $scale.wrappedValue = scale
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
        ScaleSlider(Binding.constant(.mild), "Body ache", descriptions: Scales.bodyAcheDescriptions)
        ScaleSlider(Binding.constant(.moderate), "Dryness", descriptions: Scales.drynessDescriptions)
        ScaleSlider(Binding.constant(.severe), "Wetness", descriptions: Scales.wetnessDescriptions)
        ScaleSlider(Binding.constant(.extreme), "Risk", descriptions: Scales.foodRiskDescriptions)
        ScaleSlider(Binding.constant(.large), "Meal size", descriptions: FoodSizes.descriptions)
      }
    }
  }
}
