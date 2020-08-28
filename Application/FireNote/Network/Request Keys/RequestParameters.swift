//
//  RequestParameters.swift
//  FireNote
//
//  Created by Denis Kovalev on 28.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

/// Null value as a parameter value
let parameterNullValue = NSNull()

/// A protocol to define the request parameters
protocol RequestParametersRepresentable {
    var parameters: ParametersDictionary { get }
}

/// A protocol for enums, which should be considered as keys for request parameters
protocol RequestKey: RawRepresentable where Self.RawValue == String {}

/// A request parameters struct
struct RequestParameters<K: RequestKey>: RequestParametersRepresentable {
    private(set) var parameters: ParametersDictionary = [:]

    subscript(key: K) -> Any? {
        set {
            if let newValue = newValue as? RequestParametersRepresentable {
                parameters[key.rawValue] = newValue.parameters
            } else {
                parameters[key.rawValue] = newValue
            }
        }

        get {
            return parameters[key.rawValue]
        }
    }
}

/// Convenient alias for parameters dictionary
typealias ParametersDictionary = [String: Any]
