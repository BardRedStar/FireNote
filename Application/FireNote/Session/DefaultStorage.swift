//
//  DefaultStorage.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import SwiftKeychainWrapper

/// A lass for processing data operations with keychain
class DefaultStorage {
    // MARK: - Enumerators

    /// Represents the keys to store data in keychain
    private enum Keys {
        static let userCredentials = "user_credentials"
    }

    // MARK: - Properties and variables

    private let keychain = KeychainManager.sharedKeychainWrapper

    var userCredentials: UserCredentials? {
        set {
            set(newValue, forKey: Keys.userCredentials)
        }
        get {
            return object(ofType: UserCredentials.self, forKey: Keys.userCredentials)
        }
    }

    // MARK: - Generic Helpers

    func set<T: Codable>(_ object: T?, forKey key: String) {
        if let object = object {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(object) {
                keychain.set(data, forKey: key)
            }
        } else {
            keychain.removeObject(forKey: key)
        }
    }

    func object<T: Codable>(ofType type: T.Type, forKey key: String) -> T? {
        guard let data = keychain.data(forKey: key) else {
            return nil
        }

        let decoder = JSONDecoder()
        guard let object = try? decoder.decode(type.self, from: data) else {
            return nil
        }

        return object
    }
}

// MARK: - Convenient Models

struct UserCredentials: Codable {
    let email: String
    let password: String
}
