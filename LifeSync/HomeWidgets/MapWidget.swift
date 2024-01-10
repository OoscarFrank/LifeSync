//
//  MapWidget.swift
//  LifeSync
//
//  Created by Oscar Frank on 09/12/2023.
//

import SwiftUI
import MapKit
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        userLocation = location.coordinate
    }
}

struct MapWidget: View {
    @StateObject private var locationManager = LocationManager()
    @State private var localAdresseDomicile: String = UserDefaults.standard.string(forKey: "adresseDomicile") ?? ""
    @State private var localAdresseTravail: String = UserDefaults.standard.string(forKey: "adresseTravail") ?? ""

    @State private var homeLatitude: Double = 0
    @State private var homeLongitude: Double = 0
    @State private var workLatitude: Double = 0
    @State private var workLongitude: Double = 0
    @State private var isLoading = true

    private func calculateDistance(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CLLocationDistance {
        let sourceLocation = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return sourceLocation.distance(from: destinationLocation) / 1000
    }

    var body: some View {
        VStack {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity)
                } else {
                    Map(coordinateRegion: $locationManager.region, showsUserLocation: true)
                        .cornerRadius(20)
                        .frame(height: 150)
                        .overlay(
                            GeometryReader { geo in
                                if let userLocation = locationManager.userLocation {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 5, height: 5)
                                        .position(
                                            x: geo.size.width * CGFloat((userLocation.longitude - locationManager.region.center.longitude) / locationManager.region.span.longitudeDelta),
                                            y: geo.size.height * CGFloat((locationManager.region.center.latitude - userLocation.latitude) / locationManager.region.span.latitudeDelta)
                                        )
                                }
                            }
                        )
                }
            }
            .cornerRadius(20)
            .clipped()
            .padding()

            if !isLoading {
                if let userLocation = locationManager.userLocation {
                    let isAtHome = calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: homeLatitude, longitude: homeLongitude)) <= 1.0
                    let isAtWork = calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: workLatitude, longitude: workLongitude)) <= 1.0
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.0))
                        .frame(height: 50)
                        .overlay(
                            HStack {
                                HStack {
                                    Text("Home's at")
                                    if isAtHome {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Text("\(String(format: "%.2f", calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: homeLatitude, longitude: homeLongitude)))) km")
                                    }
                                }
                                .frame(maxWidth: .infinity)

                                Divider()

                                HStack {
                                    Text("Work's at")
                                    if isAtWork {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Text("\(String(format: "%.2f", calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: workLatitude, longitude: workLongitude)))) km")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        )
                }
            }
        }
        .onAppear {
            geocodeAddress(localAdresseDomicile) { coordinates in
                if let coordinates = coordinates {
                    homeLatitude = coordinates.latitude
                    homeLongitude = coordinates.longitude
                } else {
                    print("Impossible de géocoder l'adresse de domicile")
                }
                isLoading = false
            }

            geocodeAddress(localAdresseTravail) { coordinates in
                if let coordinates = coordinates {
                    workLatitude = coordinates.latitude
                    workLongitude = coordinates.longitude
                } else {
                    print("Impossible de géocoder l'adresse de travail")
                }
                isLoading = false
            }
        }
    }
}

func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) { placemarks, error in
        if let error = error {
            print("Erreur de géocodage : \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        if let placemark = placemarks?.first,
           let location = placemark.location?.coordinate {
            completion(location)
        } else {
            completion(nil)
        }
    }
}

struct MapWidget_Previews: PreviewProvider {
    static var previews: some View {
        MapWidget()
    }
}
