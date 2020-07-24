//
//  LocationPickerModels.swift
//  FireNote
//
//  Created by Denis Kovalev on 23.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import GoogleMaps
import GooglePlaces

struct LocationItem {
    var coordinate: CLLocationCoordinate2D
    var formattedAddress: String
}

struct LocationSuggestionItem {
    var placeId: String
    var address: String

    init(placeId: String, address: String) {
        self.placeId = placeId
        self.address = address
    }

    init?(_ prediction: GMSAutocompletePrediction) {
        if let address = prediction.attributedSecondaryText?.string {
            self.init(placeId: prediction.placeID, address: address)
        }
        return nil
    }
}
