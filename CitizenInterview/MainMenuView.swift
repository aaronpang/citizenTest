//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import CoreLocation
import SwiftUI

enum OfficialRole: String, Codable {
    case none
    case president
    case vicePresident
    case senator
    case representative
    case governor
}

struct Official: Codable {
    let name: String
    let party: String
    let role: OfficialRole
}

struct OfficeResult: Decodable {
    let levels: [String]
    let roles: [String]
    let officialIndices: [Int]
}

struct OfficialResult: Decodable {
    let name: String
    let party: String
}

struct RepresentativesResult: Decodable {
    let offices: [OfficeResult]
    let officials: [OfficialResult]
}

struct MainMenuView: View {
    @State private var selection: Bool = false
    @State private var isLoading: Bool = false
    @State private var selectedState: AmericanState = .alabama
    @State private var isAbove65 = false
    @State private var locationEnabled = false
    @State private var answerModel: DynamicAnswerResultsModel?
    @StateObject var locationManager = LocationManager()

    enum AmericanState: String, CaseIterable, Identifiable {
        case alabama, alaska, arizona, arkansas, california, colorado, connecticut, delaware, florida, georgia, hawaii, idaho, illinois, indiana, iowa, kansas, kentucky, louisiana, maine, maryland, massachusetts, michigan, minnesota, mississippi, missouri, montana, nebraska, nevada, new_hampshire, new_jersey, new_mexico, new_york, north_carolina, north_dakota, ohio, oklahoma, oregon, pennsylvania, rhode_island, south_carolina, south_dakota, tennessee, texas, utah, vermont, virginia, washington, west_virginia, wisconsin, wyoming
        var id: Self { self }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Please accept the location access so we can provide to you the most accurate information for your studies").onAppear {
                    // Check if location is enabled on appear
                    // Depending on permissions, show different UIs (request button, address, or state picker)
                    switch locationManager.manager.authorizationStatus {
                    case .notDetermined: break
                    // Show authorization button
                    case .denied: break
                    case .restricted: break
                    // Show picker and button to screen to allow authorization
                    case .authorizedAlways:
                        locationManager.manager.requestLocation()

                    case .authorizedWhenInUse:
                        // Sweet get the user location and see if it needs to be stored
                        locationManager.manager.requestLocation()
                    @unknown default:
                        break
                    }
                }
                if locationManager.authorization == .authorizedAlways || locationManager.authorization == .authorizedWhenInUse {
                    Text(String(format: "The address we are using is:\n%@", locationManager.location))
                } else if locationManager.authorization == .notDetermined {
                    Toggle("Location Enabled", isOn: $locationEnabled)
                        .toggleStyle(.switch)
                        .frame(alignment: .bottom).padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                        .tint(Color(UIColor.systemBlue))
                        .onChange(of: locationEnabled) { _ in
                            locationManager.manager.requestWhenInUseAuthorization()
                        }
                } else {
                    Picker("Pick Your State", selection: $selectedState, content: {
                        ForEach(AmericanState.allCases) { americanState in
                            Text(americanState.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                        }
                    })
                    .pickerStyle(.wheel)
                    .onChange(of: selectedState) { _ in
                    }
                }

                // If the user declines the location, then show a picker for them to pick the state
                Toggle("Above the age of 65?", isOn: $isAbove65)
                    .toggleStyle(.switch)
                    .frame(alignment: .bottom).padding(EdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0))
                    .tint(Color(UIColor.systemBlue))
                Button {
                    // Fetch the info on the state-specific questions
                    isLoading = true
                    fetchData { dynamicAnswers, error in
                        isLoading = false
                        if let error = error {
                            print(error)
                        } else {
                            answerModel = dynamicAnswers
                            selection = true
                        }
                    }
                } label: {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 40)
                            .tint(.white)
                    } else {
                        Text("Begin Quiz")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor.systemBlue.withAlphaComponent(isLoading ? 0.8 : 1.0)))
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding()
            }
            .navigationBarTitle(Text("US Citizenship Prep"))
            .navigationDestination(isPresented: $selection) {
                FlashcardView(answerModel: $answerModel)
            }
            .padding()
        }
    }

    func fetchData(completion: @escaping (DynamicAnswerResultsModel?, Error?) -> Void) {
        // Check if the data is cached with a refresh date of < 2 months, then fetch the info
        var urlComponents = URLComponents(string: "https://www.googleapis.com/civicinfo/v2/representatives")!
        urlComponents.queryItems = [
            URLQueryItem(name: "address", value: locationManager.location),
            URLQueryItem(name: "key", value: "AIzaSyCOGbH_RzRwROVMroT7EFklR9sVpIj43Y4")
        ]
        let url = urlComponents.url!

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            do {
                let representativeResults = try JSONDecoder().decode(RepresentativesResult.self, from: data)
                // Create list of officials with their official name
                var officials: [Official] = []
                for office in representativeResults.offices {
                    for officialIndex in office.officialIndices {
                        let officialResult = representativeResults.officials[officialIndex]
                        let role = officialRoleFromRolesAndLevels(roles: office.roles,
                                                                  levels: office.levels)
                        if role != .none {
                            let official = Official(name: officialResult.name,
                                                    party: officialResult.party,
                                                    role: role)
                            officials.append(official)
                        }
                    }
                }
                let senators = officalNames(officials: officials, role: .senator)
                let representatives = officalNames(officials: officials, role: .representative)
                let president = officalNames(officials: officials, role: .president)[0]
                let vicePresident = officalNames(officials: officials, role: .vicePresident)[0]
                let governor = officalNames(officials: officials, role: .governor)[0]
                let presidentPoliticalParty =
                    officials.filter {
                        $0.role == .president
                    }.map { official in
                        official.party
                    }[0]
                let answers = DynamicAnswerResultsModel(senators: senators,
                                                        representatives: representatives,
                                                        president: president,
                                                        presidentPoliticalParty: presidentPoliticalParty,
                                                        vicePresident: vicePresident,
                                                        governor: governor,
                                                        capital: "",
                                                        speakerOfHouse: "Kevin McCarthy",
                                                        numberOfSupremeCourtJustices: 9,
                                                        chiefJustice: "John Roberts") // Don't hard code these

                completion(answers, nil)
            } catch {
                print(error)
                completion(nil, error)
            }
        }
        task.resume()
    }

    func officalNames(officials: [Official], role: OfficialRole) -> [String] {
        let names = officials.filter {
            $0.role == role
        }.map { official in
            official.name
        }
        if names.count <= 0 {
            return [String(format: "There are no %@s for the address: %@", role.rawValue, locationManager.location)]
        }
        return names
    }

    func officialRoleFromRolesAndLevels(roles: [String], levels: [String]) -> OfficialRole {
        if roles.contains("headOfGovernment") {
            // President or Governor
            if levels.contains("country") {
                return .president
            } else if levels.contains("administrativeArea1") {
                return .governor
            }
        }
        if roles.contains("deputyHeadOfGovernment") && levels.contains("country") {
            return .vicePresident
        }
        if roles.contains("legislatorUpperBody") && levels.contains("country") {
            return .senator
        }
        if roles.contains("legislatorLowerBody") && levels.contains("country") {
            return .representative
        }
        return .none
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: String = ""
    @Published var authorization: CLAuthorizationStatus = .notDetermined

    var manager = {
        let manager = CLLocationManager()
        return manager
    }()

    override init() {
        super.init()
        manager.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = "3 Court Square West, NY"
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
