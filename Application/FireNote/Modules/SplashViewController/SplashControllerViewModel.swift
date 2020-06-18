//
//  SplashControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A class to operate with data for splash screen
class SplashControllerViewModel: AbstractControllerViewModel {

    // MARK: - API Calls

    func login(completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let credentials = session.defaultStorage.userCredentials else {
            completion(.success(()))
            return
        }

        session.apiManager.loginWith(email: credentials.email, password: credentials.password) { [weak self] result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                self?.session.defaultStorage.userCredentials = nil
                completion(.failure(error))
            }
        }
    }
}
