//
//  AuthNavigationController.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class to coordinate the auth flow navigation
class AuthNavigationController: UINavigationController {
    // MARK: - Output

    var onLogin: (() -> Void)?

    // MARK: - Initialization

    init() {
        let controller = LoginViewController.instantiate(viewModel: LoginControllerViewModel())

        controller.onLogin = { [weak self] in
            self?.onLogin?()
        }

        controller.onRegister = { [weak self] in
            self?.pushRegistration()
        }

        super.init(rootViewController: controller)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Routing

    private func pushRegistration() {
        let controller = RegistrationViewController.instantiate(viewModel: RegistrationControllerViewModel())

        controller.onRegister = { [weak self] in
            self?.onLogin?()
        }

        pushViewController(controller, animated: true)
    }

}
