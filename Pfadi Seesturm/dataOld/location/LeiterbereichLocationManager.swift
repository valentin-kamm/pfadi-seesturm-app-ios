//
//  LeiterbereichLocationManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//

import Foundation
import CoreLocation

final class LeiterbereichLocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<Void, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // function that checks whether the user is close to the schöpfli
    func checkUserLocation() async throws {
        let userLocation = try await requestUserLocation()
        let distanceToSchöpfliMeters = Constants.SCHOPFLI_LOCATION.distance(from: userLocation)
        let distanceForDisplay = distanceToSchöpfliMeters >= 1000 ? "\(Int(round(distanceToSchöpfliMeters)/1000)) km" : "\(Int(round(distanceToSchöpfliMeters))) m"
        #if DEBUG
        // do nothing
        #else
        if distanceToSchöpfliMeters > Constants.SCHOPFLIALARM_MAX_DISTANCE {
            throw PfadiSeesturmAppError.locationError(message: "Du befindest dich " + distanceForDisplay + " vom Schöpfli entfernt und kannst somit keinen Schöpflialarm auslösen.")
        }
        #endif
    }
    
    private func requestUserLocation() async throws -> CLLocation {
        guard CLLocationManager.locationServicesEnabled() else {
            throw PfadiSeesturmAppError.locationPermissionError(message: "Um diese Funktion zu nutzen, müssen die Ortungsdienste aktiviert sein.")
        }
        try await requestWhenInUseAuthorizationIfNeeded()
        return try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
    
    // function that makes sure location authorization is granted
    private func requestWhenInUseAuthorizationIfNeeded() async throws { 
        let status = manager.authorizationStatus
        switch status {
        case .authorized, .authorizedWhenInUse, .authorizedAlways:
            if manager.accuracyAuthorization == .reducedAccuracy {
                throw PfadiSeesturmAppError.locationAccuracyError(message: "Für diese Funktion muss die präzise Ortung aktiviert sein.")
            }
            return
        case .notDetermined:
            try await withCheckedThrowingContinuation { continuation in
                self.authorizationContinuation = continuation
                self.manager.requestWhenInUseAuthorization()
            }
            if manager.accuracyAuthorization == .reducedAccuracy {
                throw PfadiSeesturmAppError.locationAccuracyError(message: "Um diese Funktion nutzen zu können musst du deinen genauen Standort freigeben.")
            }
            return
        case .denied, .restricted:
            throw PfadiSeesturmAppError.locationPermissionError(message: "Um diese Funktion zu nutzen, müssen die Ortungsdienste aktiviert sein.")
        @unknown default:
            throw PfadiSeesturmAppError.locationPermissionError(message: "Um diese Funktion zu nutzen, müssen die Ortungsdienste aktiviert sein.")
        }
    }
    
    // function that is called if we receive a location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationContinuation?.resume(throwing: PfadiSeesturmAppError.locationError(message: "Es konnte kein Standort ermittelt werden."))
            locationContinuation = nil
            return
        }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
    
    // function that is called if there has been an error from the location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        locationContinuation?.resume(throwing: PfadiSeesturmAppError.locationError(message: "Es konnte kein Standort ermittelt werden."))
        locationContinuation = nil
    }
    
    // function that is called when authorization status changes (and when location manager is created)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation = authorizationContinuation else { return }
        switch manager.authorizationStatus {
        case .authorized, .authorizedWhenInUse, .authorizedAlways:
            if manager.accuracyAuthorization == .reducedAccuracy {
                continuation.resume(throwing: PfadiSeesturmAppError.locationAccuracyError(message: "Um diese Funktion nutzen zu können musst du deinen genauen Standort freigeben."))
                authorizationContinuation = nil
                return
            }
            continuation.resume(returning: ())
            authorizationContinuation = nil
        case .denied, .restricted:
            continuation.resume(throwing: PfadiSeesturmAppError.locationPermissionError(message: "Um diese Funktion zu nutzen, müssen die Ortungsdienste aktiviert sein."))
            authorizationContinuation = nil
        case .notDetermined:
            break
        @unknown default:
            continuation.resume(throwing: PfadiSeesturmAppError.locationPermissionError(message: "Um diese Funktion zu nutzen, müssen die Ortungsdienste aktiviert sein."))
            authorizationContinuation = nil
        }
    }
    
}
