//
//  GoogleMapsTarget.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Moya

/// A target for Google Maps API
enum GoogleMapsTarget {
    case geocoding(ParametersDictionary)
}

// MARK: - TargetType

extension GoogleMapsTarget: TargetType {
    var baseURL: URL {
        return URL(string: "https://maps.googleapis.com/maps/api")!
    }

    var path: String {
        var path = ""

        switch self {
        case .geocoding:
            path = "/geocode"
        }

        return path.appending("/json")
    }

    var method: Moya.Method {
        switch self {
        case .geocoding:
            return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case let .geocoding(parameters: parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

    var validationType: ValidationType {
        return .none
    }
}

// MARK: - AccessTokenAuthorizable

extension GoogleMapsTarget: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        return nil
    }
}
