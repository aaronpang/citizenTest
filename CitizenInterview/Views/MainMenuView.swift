//
//  ContentView.swift
//  CitizenInterview
//
//  Created by Aaron Pang on 8/25/23.
//

import CoreLocation
import SwiftUI

struct MainMenuView: View {
    @State private var showFlashCards: Bool = false
    @State private var showInfo: Bool = false
    @State private var showOptions: Bool = false
    @State private var showChecklist: Bool = false

    @State private var isLoading: Bool = false
    @State private var selectedState: AmericanState = .alabama
    @State private var isAbove65 = false
    @State private var locationEnabled = false
    @State private var answerModel: DynamicAnswerResultsModel?

    @State private var orderedQuestionsUnranked: Bool = false

    @StateObject var locationManager = LocationManager()

    enum AmericanState: String, CaseIterable, Identifiable {
        case alabama, alaska, arizona, arkansas, california, colorado, connecticut, delaware, florida, georgia, hawaii, idaho, illinois, indiana, iowa, kansas, kentucky, louisiana, maine, maryland, massachusetts, michigan, minnesota, mississippi, missouri, montana, nebraska, nevada, new_hampshire, new_jersey, new_mexico, new_york, north_carolina, north_dakota, ohio, oklahoma, oregon, pennsylvania, rhode_island, south_carolina, south_dakota, tennessee, texas, utah, vermont, virginia, washington, west_virginia, wisconsin, wyoming
        var id: Self { self }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                if locationManager.authorization == .authorizedAlways || locationManager.authorization == .authorizedWhenInUse {
                    Text(String(format: "The address we are using is:\n%@", locationManager.location))
                } else if locationManager.authorization == .notDetermined {
                    Text("Please accept the location access so we can provide to you the most accurate information for your studies")
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
                    Button {
                        showChecklist.toggle()
                    } label: {
                        if isLoading {
                            ProgressView().frame(minWidth: 100, minHeight: 40)
                        } else {
                            Text("Show checklist items for day of interview")
                        }
                    }
                    .buttonStyle(.bordered)
                // If the user declines the location, then show a picker for them to pick the state
                Spacer().frame(maxHeight: .infinity)
                Button {
                    // Fetch the info on the state-specific questions
                    isLoading = true
                    QuestionManager.fetchData(locationManager: locationManager,
                                              completion: { dynamicAnswers, error in
                                                  isLoading = false
                                                  if let error = error {
                                                      print(error)
                                                  } else {
                                                      answerModel = dynamicAnswers
                                                      showFlashCards = true
                                                  }
                                              })
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
                .frame(alignment: .bottom)
                .padding()
            }
            .navigationBarTitle(Text("US Citizenship Prep"))
            .navigationDestination(isPresented: $showFlashCards) {
                FlashcardView(isAbove65: $isAbove65, answerModel: $answerModel, orderedQuestionsUnranked: $orderedQuestionsUnranked)
            }
            .navigationDestination(isPresented: $showInfo) {
                InfoView()
            }
            .navigationDestination(isPresented: $showOptions) {
                OptionsView(orderedQuestionsUnranked: $orderedQuestionsUnranked, isAbove65: $isAbove65, locationManager: locationManager)
            }
            .navigationDestination(isPresented: $showChecklist) {
                ChecklistView()
            }
            .toolbar {
                Button("Options") {
                    showOptions = true
                }
                Button("Info") {
                    showInfo = true
                }
            }
            .padding()
            .onAppear {
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
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
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
        let location = locations[0]
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { [weak self] placemarks, error in
            guard let self else { return }
            if let error = error {
                print(error)
            }

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
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
