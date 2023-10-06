//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import CoreLocation
import SwiftUI

struct CheckListItem: Identifiable {
    var id: String { return title }
    var isChecked: Bool = false
    var title: String
}

struct CheckView: View {
    @State var isChecked: Bool = false
    var title: String
    func toggle() { isChecked = !isChecked }
    var body: some View {
        HStack {
            Button(action: toggle) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle").imageScale(.large)
            }
            Text(title)
        }
    }
}

struct ChecklistView: View {
    let checkListData = [
        CheckListItem(title: "Interview Appointment Letter"),
        CheckListItem(title: "Green card"),
        CheckListItem(title: "Driver's license, or some other state-issued identification document"),
        CheckListItem(title: "Proof of current marital status and termination of prior marriages"),
        CheckListItem(title: "Proof of termination of your spouse's previous marriages (if any)"),
        CheckListItem(title: "Birth Certificate"),
        CheckListItem(title: "Complete arrest report(s), certified court disposition(s), probation report(s) (if applicable)"),
        CheckListItem(title: "Passports and travel documents (both valid and expired passports), as well as any travel documents issued by the USCIS"),
        CheckListItem(title: "Tax returns for the last 5 years (3 years if you are married to a U.S. citizen)"),
        CheckListItem(title: "List of Travel locations and dates since filing N-400"),
        CheckListItem(title: "Lease or Mortgage Statements")
    ]
    var body: some View {
        Text("This is only guidance for a list of items you should bring to your naturalization interview. It is not a comprehensive list and in some cases, USCIS may ask you to bring additional documents to the interview.").padding(.horizontal).padding(.top)
        List(checkListData) { item in
            CheckView(isChecked: item.isChecked, title: item.title)
        }.navigationBarTitle("Day Of Checklist")
    }
}
