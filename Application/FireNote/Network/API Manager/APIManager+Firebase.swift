//
//  APIManager+Firebase.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import FirebaseAuth

/// An extension, which contains requests related to Google Firebase
extension APIManager {
    func registerUserWith(email: String, password: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password, completion: { result, error in
            if result?.user != nil {
                completion(.success(()))
            }
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
        })
    }

    func loginWith(email: String, password: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            if result?.user != nil {
                completion(.success(()))
            }
            if let error = error {
                completion(.failure(.firebaseError(error)))
            }
        })
    }
}
