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
class LoginViewController: AbstractViewController, StoryboardBased {
    // MARK: - Outlets

    @IBOutlet private var passwordTextField: PasswordTextField!
    @IBOutlet private var emailTextField: PrimaryTextField!

    // MARK: - Output

    var onLogin: (() -> Void)?
    var onRegister: (() -> Void)?

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
        passwordTextField.primaryDelegate = self

        emailTextField.validationDelegate = self
        emailTextField.primaryDelegate = self
    }

    // MARK: - API methods

    private func login(email: String, password: String) {
        viewModel.loginWith(email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.onLogin?()
            case let .failure(error):
                AlertPresenter.presentErrorAlert(message: error.localizedDescription, target: self, buttonAction: nil)
            }
        }
    }

    // MARK: - UI Callbacks

    @IBAction private func loginAction(_ sender: Any) {
        validatableTextFieldDidEndEditing(emailTextField)
        validatableTextFieldDidEndEditing(passwordTextField)

        var validationErrorMessage = ""
        validationErrorMessage += emailTextField.isError ? "Email is invalid\n" : ""
        validationErrorMessage += passwordTextField.isError ?
            """
                Password should contain:
                - At least 1 lowercase and uppercase letter
                - At least 1 digit
                - At least 8 letters at all
            """ : ""

        guard validationErrorMessage.isEmpty else {
            AlertPresenter.presentErrorAlert(message: validationErrorMessage, target: self)
            return
        }

        login(email: emailTextField.text!, password: passwordTextField.currentText)
    }

    @IBAction private func registerAction(_ sender: Any) {
        onRegister?()
    }
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
        } else {
            passwordTextField.isError = !passwordTextField.currentText.isValidPassword()
        }
    }
}

// MARK: - PrimaryTextFieldDelegate

extension LoginViewController: PrimaryTextFieldDelegate {
    func primaryTextFieldDidTapReturn(_ textField: PrimaryTextField) {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            loginAction("")
        }
    }
}
