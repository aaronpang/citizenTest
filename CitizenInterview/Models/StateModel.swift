//
//  QuestionModel.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/29/23.
//

import Foundation

enum AmericanState: String, CaseIterable, Identifiable {
    case alabama, alaska, arizona, arkansas, california, colorado, connecticut, delaware, florida, georgia, hawaii, idaho, illinois, indiana, iowa, kansas, kentucky, louisiana, maine, maryland, massachusetts, michigan, minnesota, mississippi, missouri, montana, nebraska, nevada, new_hampshire, new_jersey, new_mexico, new_york, north_carolina, north_dakota, ohio, oklahoma, oregon, pennsylvania, rhode_island, south_carolina, south_dakota, tennessee, texas, utah, vermont, virginia, washington, west_virginia, wisconsin, wyoming
    var id: Self { self }
}

struct StateModel: Decodable {
    let stateName: String
    let zip: String
    let abbreviation: String
    let capital: String
}
