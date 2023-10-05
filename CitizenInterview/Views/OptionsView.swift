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

    @State var showAllQuestionsList: Bool
    @State var answerModel: DynamicAnswerResultsModel?
    @State var isLoading: Bool = false
    let locationManager: LocationManager

    init(orderedQuestionsUnranked: Binding<Bool>, isAbove65: Binding<Bool>, locationManager: LocationManager) {
        self._orderedQuestionsUnranked = orderedQuestionsUnranked
        self._isAbove65 = isAbove65
        self._showAllQuestionsList = State(initialValue: false)
        self.locationManager = locationManager
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Toggle(isOn: $orderedQuestionsUnranked) {
                    Text("Show Questions in order regardless of rank?")
                    Text("Toggling this will show questions in the order and not rank them by the ones you get wrong the most.")
                }
                .tint(Color(UIColor.systemBlue))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                Toggle(isOn: $isAbove65) {
                    Text("Are you above the age of 65 and legal permanent resident for 20 or more years?")
                    Text("Toggling this will reduce the number of question you have to study.")
                }
                .tint(Color(UIColor.systemBlue))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                HStack {
                    VStack(alignment: .leading) {
                        Text("Show all questions with answers")
                        Text("View all the questions in order with all the answers without doing the quiz.").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Button {
                        isLoading = true
                        QuestionManager.fetchData(locationManager: locationManager,
                                                  completion: { dynamicAnswers, error in
                                                      isLoading = false
                                                      if let error = error {
                                                          print(error)
                                                      } else {
                                                          showAllQuestionsList.toggle()
                                                          answerModel = dynamicAnswers
                                                      }
                                                  })
                    } label: {
                        if isLoading {
                            ProgressView().frame(minWidth: 100, minHeight: 40)
                        } else {
                            Text("Show All")
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Options"))
        .navigationDestination(isPresented: $showAllQuestionsList) {
            AllQuestionsView(answerModel: answerModel)
        }
    }
}
