//
//  ChartView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 21/3/21.
//

import Charts
import Shapes
import SwiftUI

enum Charts: String, CaseIterable {
  case overview
  case prediction
  case symptoms
}

struct ChartView: View {
  @EnvironmentObject var appState: IBSData

  @State private var sympotomsInclude: [ItemType] = [.bm, .gut, .ache, .mood, .skin]
  @State private var sympotomsIncludeBMPerDay = true
  @State private var graphScale: CGFloat = 1
  @State private var lastGraphScale: CGFloat = 1
  @State private var graphOffset: CGFloat = 0
  @State private var lastGraphOffset: CGFloat = 0
  @State private var lastRecordInterval: Double = 0

  private var activeChart: Charts {
    appState.activeChart
  }

  var body: some View {
    SymptomsView(include: $sympotomsInclude, graphScale: $graphScale, lastGraphScale: $lastGraphScale, graphOffset: $graphOffset, lastGraphOffset: $lastGraphOffset, lastRecordInterval: $lastRecordInterval)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private func chartSelector(for chart: Charts, active: Bool) -> some View {
    Button(action: { appState.activeChart = chart }) {
      chartIcon(for: chart, active: activeChart == chart)
    }
  }

  private func chartIcon(for chart: Charts, active: Bool) -> some View {
    let rotations: [Charts: Double] = [
      .symptoms: -90,
    ]

    let rotation = rotations[chart] ?? 0
    return Image(systemName: iconSystemName(for: chart))
      .resizable()
      .scaledToFit()
      .rotate(.degrees(rotation))
      .frame(25)
      .padding(10)
      .foregroundColor(active ? .blue : .secondary)
  }

  private func iconSystemName(for chart: Charts) -> String {
    switch chart {
    case .overview:
      return "chart.pie"
    case .prediction:
      return "stethoscope"
    case .symptoms:
      return "ruler"
    }
  }
}

struct ChartView_Previews: PreviewProvider {
  static var previews: some View {
    ChartView()
      .environmentObject(IBSData())
  }
}
