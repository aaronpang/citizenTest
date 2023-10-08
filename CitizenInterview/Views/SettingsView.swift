//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var orderedQuestionsUnranked: Bool
    @Binding var isAbove65: Bool
    @Binding var selectedState: AmericanState
    @Binding var overrideWithProvidedState: Bool
    @Binding var shouldFetchOnAppear: Bool

    @State var showAllQuestionsList: Bool
    @State var answerModel: DynamicAnswerResultsModel?
    @State var isLoading: Bool = false
    let locationManager: LocationManager

    init(orderedQuestionsUnranked: Binding<Bool>,
         isAbove65: Binding<Bool>,
         locationManager: LocationManager,
         selectedState: Binding<AmericanState>,
         overrideWithProvidedState: Binding<Bool>,
         shouldFetchOnAppear: Binding<Bool>)
    {
        self._orderedQuestionsUnranked = orderedQuestionsUnranked
        self._isAbove65 = isAbove65
        self._showAllQuestionsList = State(initialValue: false)
        self._selectedState = selectedState
        self._overrideWithProvidedState = overrideWithProvidedState
        self._shouldFetchOnAppear = shouldFetchOnAppear
        self.locationManager = locationManager
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Toggle(isOn: $orderedQuestionsUnranked) {
                    Text("Show Questions in order regardless of rank")
                    Text("Toggling this will show questions in the order and not rank them by the ones you get wrong the most.")
                }
                .tint(Color(UIColor.systemBlue))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                .onChange(of: orderedQuestionsUnranked) { _ in
                    UserDefaults.standard.set(orderedQuestionsUnranked, forKey: "settings_order_question_unranked")
                }
                Toggle(isOn: $isAbove65) {
                    Text("Above the age of 65 and legal permanent resident for 20 or more years")
                    Text("Toggling this will reduce the number of question you have to study.")
                }
                .tint(Color(UIColor.systemBlue))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                .onChange(of: isAbove65) { _ in
                    UserDefaults.standard.set(isAbove65, forKey: "settings_is_above_65")
                }
                Toggle(isOn: $overrideWithProvidedState) {
                    Text("Override current location with State")
                    Text("Toggling this will allow you to study with information given from another provided state.")
                }
                .tint(Color(UIColor.systemBlue))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                .onChange(of: overrideWithProvidedState) { _ in
                    if !overrideWithProvidedState {
                        shouldFetchOnAppear = true
                        locationManager.removeOverridenStateObject()
                    }
                    UserDefaults.standard.set(overrideWithProvidedState, forKey: "settings_override_with_provided_state")
                }
                if overrideWithProvidedState {
                    Picker("Choose State", selection: $selectedState, content: {
                        ForEach(AmericanState.allCases) { americanState in
                            Text(americanState.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                        }
                    })
                    .pickerStyle(.navigationLink)
                    .onChange(of: selectedState) { _ in
                        locationManager.replaceLocationWithBackupState(backupState: selectedState)
                        UserDefaults.standard.set(selectedState.rawValue, forKey: "settings_american_state")
                    }.onAppear {
                        locationManager.replaceLocationWithBackupState(backupState: selectedState)
                    }.padding(.bottom)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text("Show all questions with answers")
                        Text("View all the questions in order with all the answers without doing the quiz.").font(.subheadline).foregroundStyle(.secondary)
                    }.frame(maxWidth: .infinity)
                    Button {
                        isLoading = true
                        QuestionManager.fetchData(locationManager: locationManager,
                                                  completion: { dynamicAnswers, _ in
                                                      isLoading = false
                                                      // TODO: Error fetching
                                                      answerModel = dynamicAnswers
                                                      showAllQuestionsList.toggle()
                                                  })
                    } label: {
                        if isLoading {
                            ProgressView().frame(minWidth: 50)
                        } else {
                            Text("Show All")
                        }
                    }
                    .allowsHitTesting(!isLoading)
                    .buttonStyle(.bordered)
                }

            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Settings"))
        .navigationDestination(isPresented: $showAllQuestionsList) {
            AllQuestionsView(answerModel: answerModel)
        }
    }
}
