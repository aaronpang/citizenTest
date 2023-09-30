//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct OptionsView: View {
    @Binding var orderedQuestionsUnranked: Bool

    init(orderedQuestionsUnranked: Binding<Bool>) {
        self._orderedQuestionsUnranked = orderedQuestionsUnranked
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
//                HStack {
                Toggle(isOn: $orderedQuestionsUnranked) {
                    Text("Show Questions in Order regardless of Rank?")
                    Text("Toggling this will show questions in the order in the USCIS booklet and not show the questions you normally get wrong first.")
                }
//                }
            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Options"))
    }
}
