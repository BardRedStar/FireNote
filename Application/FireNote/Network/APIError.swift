//
//  APIError.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

enum APIError: Error {
    case firebase(Error)
    case googleMaps(Error)

    case location(CommonError)
    case permission(CommonError)

    case moya(Error)
    case decoding(Error)
    case backend(BackendError)

    var localizedDescription: String {
        switch self {
        // Cases with Error type
        case let .firebase(error), let .googleMaps(error), let .moya(error), let .decoding(error):
            return error.localizedDescription
        // Cases with CommonError type
        case let .location(error), let .permission(error):
            return error.localizedDescription
        case let .backend(error):
            return error.localizedDescription
        }
    }
}

/// Describes the error with text description, which can be initialized directly
class CommonError: Error {
    /// Error message
    let localizedDescription: String

    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }

    init(_ error: Error) {
        localizedDescription = error.localizedDescription
    }
}

/// Possible error format that can be returned by backend
class BackendError: Codable, Error {
    let localizedDescription: String

    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }

    init(_ error: Error) {
        localizedDescription = error.localizedDescription
    }

    enum CodingKey: String {
        case localizedDescription = "message"
    }

    static func decodeError(from data: Data, decoder: JSONDecoder) throws -> BackendError {
        do {
            let decodedError = try decoder.decode(BackendError.self, from: data)
            return decodedError
        } catch {
            throw error
        }
    }
}
