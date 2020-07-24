//
//  APIError.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

enum APIError: Error {
    case firebaseError(Error)
    case googleMapsError(Error)
    case locationError(CommonError)
    case permissionError(CommonError)

    var localizedDescription: String {
        switch self {
        // Cases with Error type
        case let .firebaseError(error), let .googleMapsError(error):
            return error.localizedDescription
        // Cases with CommonError type
        case let .locationError(error), let .permissionError(error):
            return error.localizedDescription
        }
    }
}

/// Describes the error with text description, which can be initialized directly
struct CommonError: Error {
    /// Error message
    let localizedDescription: String

    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }

    init(_ error: Error) {
        localizedDescription = error.localizedDescription
    }
}
