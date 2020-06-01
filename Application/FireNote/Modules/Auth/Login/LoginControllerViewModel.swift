//
//  LoginControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A class for holding the login screen data operations
class LoginControllerViewModel {

    // MARK: - API Calls
    func loginWith(email: String, password: String, completion: @escaping () -> Void) {
        delay(1.0, completion: completion)
    }
}
