//
//  RegistrationControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

/// A class for holidng the registration screen data operations
class RegistrationControllerViewModel {

    func registerWith(firstName: String, lastName: String, email: String, password: String, completion: @escaping () -> Void) {
        delay(1.0, completion: completion)
    }

}
