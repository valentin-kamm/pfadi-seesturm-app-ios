//
//  SchoepflialarmLocationService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.04.2025.
//
import CoreLocation

final class SchoepflialarmLocationService: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?
    private var authorizationContinuation: CheckedContinuation<Void, Error>?

    override init() {
        
        super.init()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func checkUserLocation() async throws {
        
        let userLocation = try await requestUserLocation()
        let distanceToSchöpfliMeters = Constants.SCHOPFLI_LOCATION.distance(from: userLocation)
        let distanceForDisplay = distanceToSchöpfliMeters >= 1000 ? "\(Int(round(distanceToSchöpfliMeters)/1000)) km" : "\(Int(round(distanceToSchöpfliMeters))) m"
        
        if !Constants.IS_DEBUG && distanceToSchöpfliMeters > Constants.SCHOPFLIALARM_MAX_DISTANCE {
            throw SchoepflialarmLocalizedError.tooFarAway(distanceDescription: distanceForDisplay)
        }
    }
    
    private func requestUserLocation() async throws -> CLLocation {
        
        guard CLLocationManager.locationServicesEnabled() else {
            throw SchoepflialarmLocalizedError.locationPermissionError
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
                throw SchoepflialarmLocalizedError.locationError(message: "Für diese Funktion muss die präzise Ortung aktiviert sein.")
            }
            return
        case .notDetermined:
            try await withCheckedThrowingContinuation { continuation in
                self.authorizationContinuation = continuation
                self.manager.requestWhenInUseAuthorization()
            }
            if manager.accuracyAuthorization == .reducedAccuracy {
                throw SchoepflialarmLocalizedError.locationError(message: "Für diese Funktion muss die präzise Ortung aktiviert sein.")
            }
            return
        case .denied, .restricted:
            throw SchoepflialarmLocalizedError.locationPermissionError
        @unknown default:
            throw SchoepflialarmLocalizedError.locationPermissionError
        }
    }
    
    // function that is called if we receive a location update
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            locationContinuation?.resume(throwing: SchoepflialarmLocalizedError.locationError(message: "Es konnte kein Standort ermittelt werden."))
            locationContinuation = nil
            return
        }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }
    
    // function that is called if there has been an error from the location manager
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        
        locationContinuation?.resume(throwing: SchoepflialarmLocalizedError.locationError(message: "Es konnte kein Standort ermittelt werden."))
        locationContinuation = nil
    }
    
    // function that is called when authorization status changes (and when location manager is created)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        guard let continuation = authorizationContinuation else {
            return
        }
        
        switch manager.authorizationStatus {
        case .authorized, .authorizedWhenInUse, .authorizedAlways:
            if manager.accuracyAuthorization == .reducedAccuracy {
                continuation.resume(throwing: SchoepflialarmLocalizedError.locationError(message: "Für diese Funktion muss die präzise Ortung aktiviert sein."))
                authorizationContinuation = nil
                return
            }
            continuation.resume(returning: ())
            authorizationContinuation = nil
        case .denied, .restricted:
            continuation.resume(throwing: SchoepflialarmLocalizedError.locationPermissionError)
            authorizationContinuation = nil
        case .notDetermined:
            break
        @unknown default:
            continuation.resume(throwing: SchoepflialarmLocalizedError.locationPermissionError)
            authorizationContinuation = nil
        }
    }
}
