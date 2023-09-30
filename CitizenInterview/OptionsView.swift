//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct OptionsView: View {
    @Binding var orderedQuestionsUnranked: Bool
    @Binding var isAbove65: Bool

    init(orderedQuestionsUnranked: Binding<Bool>, isAbove65: Binding<Bool>) {
        self._orderedQuestionsUnranked = orderedQuestionsUnranked
        self._isAbove65 = isAbove65
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Toggle(isOn: $orderedQuestionsUnranked) {
                    Text("Show Questions in order regardless of rank?")
                    Text("Toggling this will show questions in the order and not rank them by the ones you get wrong the most.")
                }.tint(Color(UIColor.systemBlue))
                Toggle(isOn: $isAbove65) {
                    Text("Are you above the age of 65 and legal permanent resident for 20 or more years?")
                    Text("Toggling this will reduce the number of question you have to study.")
                }.tint(Color(UIColor.systemBlue))
            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Options"))
    }
}
