//
//  ActionGridView.swift
//  ibs-tracker
//
//  Created by Benjamin Lewis on 15/1/21.
//

import SwiftUI

struct ActionGridView: View {
  var body: some View {
    NavigationView {
      ScrollViewReader { scroller in
        ScrollView {
          appIconButton(scroller: scroller, anchor: .bottom, rotate: .degrees(180))
          Spacer()
            .height(400)
          HStack {
            Spacer()
            VStack(alignment: .center) {
              appIconButton(scroller: scroller, anchor: .top)
              contentGrid
                .id(1)
              appIconButton(scroller: scroller, anchor: .bottom, rotate: .degrees(180))
            }
            Spacer()
          }
          Spacer()
            .height(400)
          appIconButton(scroller: scroller, anchor: .top)
        }
        .onAppear {
          scroller.scrollTo(id: 1, anchor: .bottom)
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("IBS Tracker")
        }
      }
    }
  }

  private var contentGrid: some View {
    VStack(alignment: .center) {
      PaddedHStack {
        ActionNavigationLink(type: .note, text: "Notes") { NoteFormView() }
        ActionNavigationLink(type: .medication, text: "medicaiton") { MedicationFormView() }
        ActionNavigationLink(type: .food, text: "Food") { FoodFormView() }
      }

      PaddedHStack {
        ActionNavigationLink(type: .mood, text: "Mood\nStress") { MoodFormView() }
        ActionNavigationLink(type: .ache, text: "Headache\nBody ache") { AcheFormView() }
        ActionNavigationLink(type: .gut, text: "Bloating\nPain") { GutFormView() }
      }

      PaddedHStack {
        ActionNavigationLink(type: .skin, text: "Skin") { SkinFormView() }
        ActionNavigationLink(type: .weight, text: "Weight") { WeightFormView() }
        ActionNavigationLink(type: .bm, text: "Poop") { BMFormView() }
      }
    }
    .padding(.vertical, 20)
    .frame(maxWidth: 380)
  }

  private func appIconButton(scroller: ScrollViewProxy, anchor: UnitPoint, rotate angle: Angle = .degrees(0)) -> some View {
    AppIconView()
      .contentShape(Rectangle())
      .rotate(angle)
      .foregroundColor(.secondary)
      .onTapGesture {
        withAnimation {
          scroller.scrollTo(id: 1, anchor: anchor)
        }
      }
  }
}

struct ActionGridView_Previews: PreviewProvider {
  static var previews: some View {
    ActionGridView()
  }
}

struct PaddedHStack<Content: View>: View {
  private let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    HStack {
      content()
    }
    .padding(.leading)
    .padding(.trailing)
  }
}
