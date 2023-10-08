//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import CoreLocation
import SwiftUI

struct MainMenuView: View {
    // Navigation
    @State private var showFlashCards: Bool = false
    @State private var showAbout: Bool = false
    @State private var showSettings: Bool = false
    @State private var showChecklist: Bool = false

    // UI
    @State private var isLoading: Bool = false
    @State private var locationEnabled = false
    @State private var answerModel: DynamicAnswerResultsModel?
    @State private var shouldFetchOnAppear: Bool = true

    // Settings
    @State private var isAbove65 = false
    @State private var overrideWithProvidedState: Bool = false
    @State private var orderedQuestionsUnranked: Bool = false
    @State private var selectedState: AmericanState = .alabama

    @StateObject var locationManager = LocationManager()

    var body: some View {
        let imageSize = UIScreen.main.bounds.size.width / 2
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .center) {
                    Image("main_menu_image")
                        .resizable()
                        .frame(width: imageSize, height: imageSize, alignment: .center)
                        .clipShape(.circle)
                    Text("This is an unofficial app that can help you prepare for the Civics portion of the USCIS naturalization interview.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity)
                if locationManager.authorization == .authorizedAlways || locationManager.authorization == .authorizedWhenInUse {
                    Text("It is absolutely free of charge and built with love and care ❤️.")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    Spacer().frame(maxHeight: .infinity)
                    if locationManager.isFetchingLocation {
                        HStack {
                            Text(String(format: "Fetching current location"))
                                .font(.caption2)
                                .foregroundStyle(.gray)
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.leading, 1)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 2)
                    } else if overrideWithProvidedState {
                        Text(String(format: "Overriding current location with state in Settings."))
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .padding(.leading)
                            .padding(.bottom, 2)
                    }
                    Text(String(format: "Using location: %@", locationManager.shortenedLocation))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)
                        .padding(.horizontal)
                } else if locationManager.authorization == .notDetermined {
                    VStack(alignment: .leading) {
                        Text(String(format: "Please accept location access so we can provide to you the most accurate information for your studies. If none provided, we default to '%@'", selectedState.rawValue.capitalized))
                            .fixedSize(horizontal: false, vertical: true)

                        Button {
                            locationManager.manager.requestWhenInUseAuthorization()
                        } label: {
                            Text("Enable Location")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    Spacer().frame(maxHeight: .infinity)
                } else {
                    Text("*Since you declined location access, we will fetch the information based on the capital location of the provided state.*")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                    Picker("Choose State", selection: $selectedState, content: {
                        ForEach(AmericanState.allCases) { americanState in
                            Text(americanState.rawValue.capitalized.replacingOccurrences(of: "_", with: " "))
                        }
                    })
                    .pickerStyle(.navigationLink)
                    .padding()
                    Spacer().frame(maxHeight: .infinity)
                }
                // If the user declines the location, then show a picker for them to pick the state
                Button {
                    // Fetch the info on the state-specific questions
                    isLoading = true
                    if locationManager.location.isEmpty || overrideWithProvidedState {
                        locationManager.replaceLocationWithBackupState(backupState: selectedState)
                    }
                    QuestionManager.fetchData(locationManager: locationManager,
                                              completion: { dynamicAnswers, error in
                                                  isLoading = false
                                                  if let error = error {
                                                      print(error)
                                                      // TODO: Error Fetching
                                                  }
                                                  answerModel = dynamicAnswers
                                                  showFlashCards = true
                                              })
                } label: {
                    if isLoading {
                        ProgressView().frame(maxWidth: .infinity, minHeight: 40)
                            .tint(.white)
                    } else {
                        Text("Begin Civics Quiz")
                            .frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(UIColor.systemBlue.withAlphaComponent(isLoading ? 0.8 : 1.0)))
                .frame(alignment: .bottom)
                .padding(.horizontal)
                .padding(.bottom)
                .allowsHitTesting(!isLoading)
                Button {
                    showChecklist.toggle()
                } label: {
                    Text("Interview Day Checklist")
                        .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle(Text("US Citizen Interview"))
            .navigationDestination(isPresented: $showFlashCards) {
                FlashcardView(isAbove65: $isAbove65, answerModel: $answerModel, orderedQuestionsUnranked: $orderedQuestionsUnranked)
            }
            .navigationDestination(isPresented: $showAbout) {
                AboutView()
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(orderedQuestionsUnranked: $orderedQuestionsUnranked,
                             isAbove65: $isAbove65,
                             locationManager: locationManager,
                             selectedState: $selectedState,
                             overrideWithProvidedState: $overrideWithProvidedState,
                             shouldFetchOnAppear: $shouldFetchOnAppear)
            }
            .navigationDestination(isPresented: $showChecklist) {
                ChecklistView()
            }
            .toolbar {
                Button("Settings") {
                    showSettings = true
                }
                Button("About") {
                    showAbout = true
                }
            }
            .padding()
            .onAppear {
                if shouldFetchOnAppear {
                    // Don't fetch on appear if we've already fetched
                    shouldFetchOnAppear = false
                    // Fetch latest settings
                    isAbove65 = UserDefaults.standard.bool(forKey: "settings_is_above_65")
                    overrideWithProvidedState = UserDefaults.standard.bool(forKey: "settings_override_with_provided_state")
                    orderedQuestionsUnranked = UserDefaults.standard.bool(forKey: "settings_order_question_unranked")
                    if let storedAmericanStateString = UserDefaults.standard.string(forKey: "settings_american_state"),
                       let americanState = AmericanState(rawValue: storedAmericanStateString)
                    {
                        selectedState = americanState
                    }

                    let location = UserDefaults.standard.dictionary(forKey: "cached_location")?["location"] as? String
                    let zipCode = UserDefaults.standard.dictionary(forKey: "cached_location")?["zip_code"] as? String
                    let state = UserDefaults.standard.dictionary(forKey: "cached_location")?["state"] as? String
                    let shortenedLocation = UserDefaults.standard.dictionary(forKey: "cached_location")?["shortened_location"] as? String

                    locationManager.location = location ?? ""
                    locationManager.zipCode = zipCode ?? ""
                    locationManager.state = state ?? ""
                    locationManager.shortenedLocation = shortenedLocation ?? ""

                    // Fetch the latest location data on appear (only once though)
                    if locationManager.manager.authorizationStatus == .authorizedAlways
                        || locationManager.manager.authorizationStatus == .authorizedWhenInUse
                    {
                        if overrideWithProvidedState {
                            locationManager.replaceLocationWithBackupState(backupState: selectedState)
                        } else {
                            locationManager.isFetchingLocation = true
                            locationManager.manager.requestLocation()
                        }
                    }
                }
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
    @Published var authorization: CLAuthorizationStatus = .notDetermined
    @Published var shortenedLocation: String = ""
    @Published var isFetchingLocation = false
    private var overridenStateObject: StateModel?

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
        // Don't request location if we're overriding the state
        if overridenStateObject == nil && (authorization == .authorizedWhenInUse || authorization == .authorizedAlways) {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { [weak self] placemarks, error in
            guard let self else { return }
            if let error = error {
                print(error)
            }
            self.isFetchingLocation = false

            // 2
            guard let placemark = placemarks?.first else { return }

            // 3
            let streetNumber = placemark.subThoroughfare
            let streetName = placemark.thoroughfare
            guard let city = placemark.locality else { return }
            guard let state = placemark.administrativeArea else { return }
            guard let zipCode = placemark.postalCode else { return }

            // 4
            self.state = state
            self.zipCode = zipCode
            self.location = "\(streetNumber ?? "")\(streetName ?? "")\n\(city), \(state) \(zipCode)"
            self.shortenedLocation = "\(city), \(state)"
            UserDefaults.standard.set(
                ["location": self.location,
                 "zip_code": zipCode,
                 "state": state,
                 "shortened_location": self.shortenedLocation],
                forKey: "cached_location")
        }
    }

    func replaceLocationWithBackupState(backupState: AmericanState) {
        guard let statesForName = JSONParser.parseStatesForName(),
              let stateObject = statesForName[backupState.rawValue]
        else {
            return // Error here, shouldn't happen though because we should be able to handle all selected states in the JSON (write test to ensure this)
        }
        location = stateObject.capital
        zipCode = stateObject.zip
        state = stateObject.abbreviation
        let city = stateObject.capital
        shortenedLocation = "\(city), \(state)"
        overridenStateObject = stateObject
    }

    func removeOverridenStateObject() {
        overridenStateObject = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
