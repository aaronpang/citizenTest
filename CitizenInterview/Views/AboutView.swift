//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("What is this app for?").font(Font.system(size: 20)).bold()
                Text("This is an unofficial app used to study for the U.S. Naturalization interview. It is completely free of charge to use and is open sourced with no ads throughout the app.").padding()
                Text("Why is it free?").font(Font.system(size: 20)).bold()
                Text("It is free because I, the developer, needed to study for the naturalization test myself and building this app helped me study and I want to share this with everyone else.").padding()
                Text("How does this app work?").font(Font.system(size: 20)).bold()
                Text("Each time you start the quiz we take the questions you got wrong the most and display them first to help you study better. You can change this in *'Settings'*").padding()
                Text("Why not use multiple choice?").font(Font.system(size: 20)).bold()
                Text("The actual interview does not provide you with multiple choice so you must memorize the answers.").padding()
                Text("Why do you need my location?").font(Font.system(size: 20)).bold()
                Text("We use your location to help you easily identify your representatives, your senators, and the capital of your state to help you study for the test so you don't have to look them up manually.\n\nWe use the Google Civic API database to get the most updated civic data.").padding()
                Text("Any other questions").font(Font.system(size: 20)).bold()
                Text("This is an unofficial app. For all official inquiries please visit the [official USCIS.gov website](https://www.uscis.gov/citizenship/find-study-materials-and-resources/study-for-the-test)").padding()
            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("About"))
    }
}
