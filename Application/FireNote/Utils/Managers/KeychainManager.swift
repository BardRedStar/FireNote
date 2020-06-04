//
//  KeychainManager.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import SwiftKeychainWrapper

/// Provides shared standard KeychainWrapper instance.
/// Computed property sharedKeychainWrapper checks whether it is first access after app installation
/// and removes all keys stored in keychain from previous installation if needed.
struct KeychainManager {
    private struct Keys {
        static let AppInstalled = "keychain_app_installed"
    }

    /// Shared KeychainWrapper instance to use throughout the app
    static let sharedKeychainWrapper: KeychainWrapper = {
        let userDefaults = UserDefaults.standard

        let isAppInstalled = userDefaults.bool(forKey: Keys.AppInstalled)
        if !isAppInstalled {
            KeychainWrapper.standard.removeAllKeys()
            userDefaults.set(true, forKey: Keys.AppInstalled)
            userDefaults.synchronize()
        }

        return KeychainWrapper.standard
    }()

    private init() {}
}
