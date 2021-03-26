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

  private var activeChart: Charts {
    appState.activeChart
  }

  var body: some View {
    VStack(spacing: 0) {
      if appState.tabSelection == .chart {
        Group {
          switch appState.activeChart {
          case .symptoms:
            SymptomsView()
          default:
            Text("\(activeChart.rawValue.capitalized)")
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      HStack {
        Spacer()
        HStack {
          ForEach(Charts.allCases, id: \.self) { chart in
            chartSelector(for: chart, active: activeChart == chart)
          }
          .padding(.horizontal, 10)
        }
        .padding(.bottom, 10)
        Spacer()
      }
    }
  }

  private func chartSelector(for chart: Charts, active: Bool) -> some View {
    Button(action: { appState.activeChart = chart }) {
      chartIcon(for: chart, active: activeChart == chart)
    }
  }

  private func chartIcon(for chart: Charts, active: Bool) -> some View {
    let rotations: [Charts: Double] = [
      .prediction: 90,
      .symptoms: -90,
      .overview: 90,
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
