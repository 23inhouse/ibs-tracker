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
          Text("Just like a donut.")
            .foregroundColor(.secondary)
            .font(.body)
            .fontWeight(.light)
            .align(.center)
            .rotationEffect(.degrees(180))
            .opacity(0.5)
            .lineSpacing(5)
            .padding(.horizontal, 50)
            .padding(.vertical, 25)
          appIconButton(scroller: scroller, anchor: .bottom, rotate: .degrees(180))
          Spacer()
            .height(400)
          HStack {
            Spacer()
            VStack(alignment: .center) {
              appIconButton(scroller: scroller, anchor: .top)
              contentGrid
                .scrollID(.gridContent)
              appIconButton(scroller: scroller, anchor: .bottom, rotate: .degrees(180))
            }
            Spacer()
          }
          Spacer()
            .height(400)
          appIconButton(scroller: scroller, anchor: .top)
          Text("Topologically speaking, the human body and a donut have exactly the same shape. The human GI tract and that of any creature more advanced than a parasitic flatworm, have a continous surface of skin with a hole that goes all the way through.\n\nJust like a donut.")
            .foregroundColor(.secondary)
            .font(.body)
            .fontWeight(.light)
            .align(.center)
            .opacity(0.5)
            .lineSpacing(5)
            .padding(.horizontal, 50)
            .padding(.vertical, 25)
        }
        .onAppear {
          scroller.scrollTo(id: .gridContent, anchor: .bottom, animate: false)
        }
      }
      .navigationBarTitleDisplayMode(.large)
      .toolbar {
        ToolbarItem(placement: .principal) {
          AppIconView(size: 25)
        }
      }
    }
  }

  private var contentGrid: some View {
    VStack(alignment: .center) {
      PaddedHStack {
        ActionNavigationLink(type: .note, text: "Notes") { NoteFormView() }
        ActionNavigationLink(type: .medication, text: "Medication") { MedicationFormView() }
        ActionNavigationLink(type: .food, text: "Food") { FoodFormView() }
      }

      PaddedHStack {
        ActionNavigationLink(type: .mood, text: "Mood\nStress") { MoodFormView() }
        ActionNavigationLink(type: .ache, text: "Headache\nBody pain") { AcheFormView() }
        ActionNavigationLink(type: .gut, text: "Pain\nBloating") { GutFormView() }
      }

      PaddedHStack {
        ActionNavigationLink(type: .skin, text: "Skin\ncondition") { SkinFormView() }
        ActionNavigationLink(type: .weight, text: "Weight") { WeightFormView() }
        ActionNavigationLink(type: .bm, text: "Poop") { BMFormView() }
      }
    }
    .padding(.vertical, 20)
    .frame(maxWidth: 380)
  }

  private func appIconButton(scroller: ScrollViewProxy, anchor: UnitPoint, rotate angle: Angle = .degrees(0)) -> some View {
    AppIconButton(angle: angle)
      .onTapGesture {
        scroller.scrollTo(id: .gridContent, anchor: anchor)
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
