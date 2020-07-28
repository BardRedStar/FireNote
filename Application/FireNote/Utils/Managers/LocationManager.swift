//
//  LocationManager.swift
//  FireNote
//
//  Created by Denis Kovalev on 23.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import GoogleMaps
import GooglePlaces

/// A protocol to provide the events of LocationManager class
protocol LocationManagerDelegate: AnyObject {
    /// Called, when the user's location was updated by request
    func locationManager(_ manager: LocationManager, didUpdateUserLocation result: Result<CLLocationCoordinate2D, APIError>)
}

/// A class to perform the location operations, such as receiving geolocation,
/// address of the place and autocompletion suggestions for address
class LocationManager: NSObject {
    // MARK: - Properties and variables

    /// Location manager from Core Location. Used for defining the current position.
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.delegate = self
        return manager
    }()

    /// Places client from Google Maps SDK
    private let placesClient = GMSPlacesClient.shared()

    /// Google Maps session token.
    private lazy var gmsSessionToken = GMSAutocompleteSessionToken()

    /// Google Maps geocoder
    private lazy var gmsGeocoder = GMSGeocoder()

    /// Delegate to provide callbacks
    weak var delegate: LocationManagerDelegate?

    // MARK: - Public Methods

    /// Gets the suggestions for query text
    func fetchSuggestionsFor(text: String, completion: @escaping (Result<[GMSAutocompletePrediction], APIError>) -> Void) {
        placesClient.findAutocompletePredictions(fromQuery: text, filter: nil, sessionToken: gmsSessionToken) { results, error in
            if let error = error {
                completion(.failure(.googleMapsError(error)))
            }
            if let results = results {
                completion(.success(results))
            }
        }
    }

    /// Gets the address and location for place with string id
    func fetchPlaceInfoFor(placeId: String, completion: @escaping (Result<GMSPlace, APIError>) -> Void) {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))!

        placesClient.fetchPlace(fromPlaceID: placeId, placeFields: fields, sessionToken: gmsSessionToken) { [weak self] place, error in
            if let error = error {
                completion(.failure(.googleMapsError(error)))
            }
            if let place = place {
                completion(.success(place))
            }
            self?.updateMapSessionToken()
        }
    }

    /// Gets the formatted address from coordinates (via Google Maps Geocoding API)
    func fetchAddressFrom(_ coordinate: CLLocationCoordinate2D, completion: @escaping (Result<String, APIError>) -> Void) {
        gmsGeocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let error = error {
                completion(.failure(.googleMapsError(error)))
                return
            }

            if let address = response?.firstResult()?.lines?.first {
                print(response?.firstResult()?.lines)
                completion(.success(address))
            } else {
                completion(.success("\(coordinate.latitude), \(coordinate.longitude)"))
            }
        }
        
    }


    /// Checks user's location permission and gets location or shows the request permission alert
    func requestUserLocation() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                locationManager.requestWhenInUseAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.requestLocation()
            @unknown default:
                break
            }
        }
    }

    // MARK: - Private Methods

    /// Updates the session token
    ///
    /// Note: Token update is necessary after each fetch request, where place is fetched by place ID.
    ///       Don't update token after autocomplete suggestions request.
    private func updateMapSessionToken() {
        gmsSessionToken = GMSAutocompleteSessionToken()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
            return
        }

        let error = CommonError("Permission was denied :(")
        delegate?.locationManager(self, didUpdateUserLocation: .failure(.locationError(error)))
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            delegate?.locationManager(self, didUpdateUserLocation: .success(location.coordinate))
            return
        }

        let error = CommonError("Can't get user location.")
        delegate?.locationManager(self, didUpdateUserLocation: .failure(.locationError(error)))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationManager(self, didUpdateUserLocation: .failure(.locationError(CommonError(error))))
    }
}
