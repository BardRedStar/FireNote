//
//  AppSession.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

/// Application session class
class Session {
    // MARK: - Properties and variables

    let apiManager: APIManager
    let dataManager: DataManager
    let defaultStorage: DefaultStorage

    var isAuthorized: Bool {
        return dataManager.user != nil
    }

    // MARK: - Initialization

    init(apiManager: APIManager, dataManager: DataManager, defaultStorage: DefaultStorage) {
        self.apiManager = apiManager
        self.dataManager = dataManager
        self.defaultStorage = defaultStorage
    }
}
