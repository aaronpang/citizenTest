//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct OptionsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("This is an unofficial app used to study for the U.S. Naturalization interview. It is completely free of charge to use and is opened sourced with no ads throughout the app.")
                Text("The app is free because I (the creator) needed to study for the test myself and I wanted to build something that would help others study for free as well. The information is free, therefore the app should be free as well.")
                Text("How the app works")
                Text("We use google civics API information to fetch the latest info on your representatives, senators, and governments.")
                Text("We use your location to help you easily identify your representatives, your senators, and the capital of your state to help you study for the test.")
            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Options"))
    }
}
