//
//  GoogleMapsBaseResponseModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A protocol to conform to Google Maps/Places API requests
protocol GoogleMapsResponseRepresentable {
    associatedtype ResultType

    var errorMessage: String? { get set }
    var status: String { get set }
    var results: [ResultType] { get set }
}

/// A base class for responses of Google Maps/Places API
class GoogleMapsResponseModel<ResultType: Codable>: Codable, GoogleMapsResponseRepresentable {
    var errorMessage: String?
    var status: String
    var results: [ResultType]

    var firstResult: ResultType? {
        return results.first
    }

    enum CodableKeys: String {
        case errorMessage = "error_message"
        case status
        case results
    }
}
