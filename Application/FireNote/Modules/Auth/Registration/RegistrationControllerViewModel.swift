//
//  RegistrationControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A class for holidng the registration screen data operations
class RegistrationControllerViewModel: AbstractControllerViewModel {

    // MARK: - API Calls

    func registerWith(firstName: String, lastName: String, email: String, password: String,
                      completion: @escaping (Result<Void, APIError>) -> Void) {
        session.apiManager.registerUserWith(email: email, password: password) { [weak self] result in
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
