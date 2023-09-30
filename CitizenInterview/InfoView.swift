//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Why is this app free?").font(Font.system(size: 20)).bold()
                Text("This is an unofficial app used to study for the U.S. Naturalization interview. It is completely free of charge to use and is open sourced with no ads throughout the app. It is free because I, (the developer) needed to study for the naturalization test myself and wanted to share it with others that needed to study as well.").padding()
                Text("How does this app work?").font(Font.system(size: 20)).bold()
                Text("Each time you start the quiz we take the questions you got wrong the most and display them first to help you study better. You can change this in 'Options'").padding()
                Text("Why not use multiple choice?").font(Font.system(size: 20)).bold()
                Text("The actual interview does not provide you with multiple choice so you must memorize the answers.").padding()
                Text("Why do you need location data?").font(Font.system(size: 20)).bold()
                Text("We use your location to help you easily identify your representatives, your senators, and the capital of your state to help you study for the test.").padding()
                Text("Any other questions").font(Font.system(size: 20)).bold()
                Text("This is an unofficial app. For all official inquiries please visit the [official USCIS.gov website](https://www.uscis.gov/citizenship/find-study-materials-and-resources/study-for-the-test)").padding()
            }.padding()
        }
        .frame(maxWidth: .infinity, // Full Screen Width
               maxHeight: .infinity, // Full Screen Height
               alignment: .topLeading)
        .navigationBarTitle(Text("Info"))
    }
}
