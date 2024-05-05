//
//  LocationService.swift
//  GeoStream
//
//  Created by Matthew Dowling on 5/5/24.
//

import SwiftUI
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var userIsSharingLocation = false
    static let shared = LocationService()
    override private init() {
        super.init()
        manager.delegate = self
        startLocationServices()
    }
    
    func startLocationServices() {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            userIsSharingLocation = true
        } else {
            userIsSharingLocation = false
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            userIsSharingLocation = true
            manager.requestLocation()
        case .notDetermined:
            userIsSharingLocation = false
            manager.requestWhenInUseAuthorization()
        case .denied:
            userIsSharingLocation = false
            print("access denied\n")
        default:
            userIsSharingLocation = true
            startLocationServices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[DEBUG ERROR] LocationManager: didFailWithError: \(error.localizedDescription)\n")
    }
}
