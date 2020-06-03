//
//  DataManager.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import FirebaseAuth

class DataManager {
    var user: User? {
        return Auth.auth().currentUser
    }
}
