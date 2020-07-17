//
//  AbstractControllerViewModel.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

/// A class, which contains a common logic for controller view models
class AbstractControllerViewModel {
    // MARK: - Properties and variables

    let session: Session

    // MARK: - Initialization

    init(session: Session) {
        self.session = session
    }
}
