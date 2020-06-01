//
//  DeepLink.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

/// A struct describing the deep link structure
struct DeepLink: Equatable {
    // MARK: - Enumerators

    /// Represents the deep link targets
    enum Target: Equatable {
    }

    // MARK: - Properties and variables

    /// A target of a deep link.
    let target: Target

    // MARK: - Initialization

    init?(url: URL) {
        guard let components = URLComponents(url: url.absoluteURL, resolvingAgainstBaseURL: true) else { return nil }

        var componentsArray: [String] = []

        var pathComponents = components.path.components(separatedBy: "/")
        if pathComponents.first == "" {
            pathComponents.removeFirst()
        }

        if let queryItems = components.queryItems {
            queryItems.forEach {
                guard let value = $0.value else { return }
                pathComponents.append(value)
            }
        }

        componentsArray.append(contentsOf: pathComponents)
        var iter = componentsArray.makeIterator()

        switch (iter.next(), iter.next(), iter.next(), iter.next()) {
        case let ("first"?, "second"?, value1, value2):
            return nil
        default:
            return nil
        }
    }
}

