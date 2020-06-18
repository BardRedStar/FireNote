//
//  LoginControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A class for holding the login screen data operations
class LoginControllerViewModel: AbstractControllerViewModel {

    // MARK: - API Calls

    func loginWith(email: String, password: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        session.apiManager.loginWith(email: email, password: password) { [weak self] result in
            switch result {
            case .success:
                self?.session.defaultStorage.userCredentials = UserCredentials(email: email, password: password)
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
