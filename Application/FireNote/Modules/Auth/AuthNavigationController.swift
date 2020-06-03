//
//  AuthNavigationController.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class to coordinate the auth flow navigation
class AuthNavigationController: AbstractNavigationController {
    // MARK: - Output

    var onLogin: (() -> Void)?

    // MARK: - Initialization

    override func setupRootViewController() -> UIViewController {
        let controller = LoginViewController.instantiate(viewModel: LoginControllerViewModel(session: session))

        controller.onLogin = { [weak self] in
            self?.onLogin?()
        }

        controller.onRegister = { [weak self] in
            self?.pushRegistration()
        }

        return controller
    }

    override func setupNavigationBarAppearance() {
        super.setupNavigationBarAppearance()
        makeNavigationBarTransparent()
    }

    // MARK: - Routing

    private func pushRegistration() {
        let controller = RegistrationViewController.instantiate(viewModel: RegistrationControllerViewModel(session: session))

        controller.onRegister = { [weak self] in
            self?.onLogin?()
        }

        controller.onBack = { [weak self] in
            self?.popViewController(animated: true)
        }

        pushViewController(controller, animated: true)
    }
}
