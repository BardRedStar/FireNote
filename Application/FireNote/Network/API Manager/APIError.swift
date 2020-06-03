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

    var localizedDescription: String {
        switch self {
        case let .firebaseError(error): return error.localizedDescription
        }
    }
}
