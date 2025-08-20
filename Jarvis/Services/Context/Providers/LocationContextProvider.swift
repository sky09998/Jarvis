//
//  LocationContextProvider.swift
//  Jarvis
//
//  Created by AI Assistant on 19/8/25.
//

import Foundation
import CoreLocation

final class LocationContextProvider: NSObject, ContextProvider, CLLocationManagerDelegate {
    let name: String = "location"
    private let manager = CLLocationManager()
    private var completion: (([String: Any]) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func fetchContext(completion: @escaping ([String : Any]) -> Void) {
        self.completion = completion
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            completion?([:])
            completion = nil
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            var context: [String: Any] = [
                "precision": "approximate",
                "lat": location.coordinate.latitude,
                "lon": location.coordinate.longitude
            ]
            if let placemark = placemarks?.first {
                context["city"] = placemark.locality ?? placemark.subLocality
                context["region"] = placemark.administrativeArea
                context["country"] = placemark.isoCountryCode
            }
            self?.completion?(context)
            self?.completion = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completion?([:])
        completion = nil
    }
}


