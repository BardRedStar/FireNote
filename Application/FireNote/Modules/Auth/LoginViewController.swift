//
//  LoginViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import FirebaseUI
import Reusable
import UIKit

/// A controller class for splash screen
class LoginViewController: UIViewController, StoryboardBased {
    // MARK: - Outlets

    @IBOutlet private var passwordTextField: PasswordTextField!
    @IBOutlet private var emailTextField: PrimaryTextField!

    // MARK: - Output

    var onFinish: (() -> Void)?

    // MARK: - Properties and variables

    private var viewModel: LoginControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: LoginControllerViewModel) -> LoginViewController {
        let controller = LoginViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI Methods

    private func setupUI() {
        passwordTextField.secureTextEntry = true
        passwordTextField.validationDelegate = self

        emailTextField.validationDelegate = self
    }

    private func auth() {}

    // MARK: - UI Callbacks

    @IBAction func loginAction(_ sender: Any) {}

    @IBAction func registerAction(_ sender: Any) {}
}

// MARK: - ValidatableTextFieldDelegate

extension LoginViewController: ValidatableTextFieldDelegate {
    func validatableTextFieldDidChangeText(_ errorTextField: ErrorTextField) {
        if errorTextField.isError {
            errorTextField.isError = false
        }
    }

    func validatableTextFieldDidEndEditing(_ errorTextField: ErrorTextField) {
        if errorTextField === emailTextField {
            emailTextField.isError = !(emailTextField.text ?? "").isValidEmail()
        }

        if errorTextField === passwordTextField {
            passwordTextField.isError = !passwordTextField.currentText.isValidPassword()
        }
    }
}
