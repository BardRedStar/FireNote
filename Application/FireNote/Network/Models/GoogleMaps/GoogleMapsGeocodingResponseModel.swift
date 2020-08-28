//
//  GoogleMapsGeocodingResponseModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// Google maps geocoding response model
class GoogleMapsGeocodingResponseModel: GoogleMapsResponseModel<GoogleMapsGeocodingResponseModel.GeocodingModel> {
    /// Result object type for geocoding request
    class GeocodingModel: Codable {
        let formattedAddress: String
        let geometry: Geometry

        enum CodableKeys: String {
            case formattedAddress = "formatted_address"
            case geometry
        }
    }

    /// "geometry" field of GeocodingModel object
    struct Geometry: Codable {
        let location: Location
    }

    /// "location" field of Geometry object
    struct Location: Codable {
        let lat: Double
        let lng: Double
    }
}
