//
//  RegistrationViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import FirebaseUI
import Reusable
import UIKit

/// A controller class for registration screen
class RegistrationViewController: AbstractViewController, StoryboardBased {
    // MARK: - Outlets

    @IBOutlet var emailTextField: PrimaryTextField!
    @IBOutlet var passwordTextField: PasswordTextField!
    @IBOutlet var lastNameTextField: PrimaryTextField!
    @IBOutlet var firstNameTextField: PrimaryTextField!

    // MARK: - Output

    var onRegister: (() -> Void)?

    // MARK: - Properties and variables

    private var viewModel: RegistrationControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: RegistrationControllerViewModel) -> RegistrationViewController {
        let controller = RegistrationViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - UI Methods

    private func setupUI() {
        emailTextField.validationDelegate = self
        lastNameTextField.validationDelegate = self
        firstNameTextField.validationDelegate = self
        passwordTextField.validationDelegate = self

        emailTextField.primaryDelegate = self
        lastNameTextField.primaryDelegate = self
        firstNameTextField.primaryDelegate = self
        passwordTextField.primaryDelegate = self

        passwordTextField.secureTextEntry = true
    }

    // MARK: - API methods

    func register(firstName: String, lastName: String, email: String, password: String) {
        viewModel.registerWith(firstName: firstName, lastName: lastName, email: email, password: password) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.onRegister?()
            case let .failure(error):
                AlertPresenter.presentErrorAlert(message: error.localizedDescription, target: self, buttonAction: nil)
            }
        }
    }

    // MARK: - UI Callbacks

    @IBAction private func registerAction(_ sender: Any) {
        validatableTextFieldDidEndEditing(emailTextField)
        validatableTextFieldDidEndEditing(passwordTextField)
        validatableTextFieldDidEndEditing(firstNameTextField)
        validatableTextFieldDidEndEditing(lastNameTextField)

        var validationErrorMessage = ""
        validationErrorMessage += firstNameTextField.isError ? "First name is invalid" : ""
        validationErrorMessage += lastNameTextField.isError ? "Last name is invalid" : ""
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

        register(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!,
                 email: emailTextField.text!, password: passwordTextField.currentText)
    }

    @IBAction private func logInAction(_ sender: Any) {
        onBack?()
    }
}

// MARK: - ValidatableTextFieldDelegate

extension RegistrationViewController: ValidatableTextFieldDelegate {
    func validatableTextFieldDidChangeText(_ errorTextField: ErrorTextField) {
        if errorTextField.isError {
            errorTextField.isError = false
        }
    }

    func validatableTextFieldDidEndEditing(_ errorTextField: ErrorTextField) {
        if errorTextField === emailTextField {
            emailTextField.isError = !(emailTextField.text ?? "").isValidEmail()
        } else if errorTextField === passwordTextField {
            passwordTextField.isError = !passwordTextField.currentText.isValidPassword()
        } else {
            errorTextField.isError = errorTextField.text?.isEmpty ?? true
        }
    }
}

// MARK: - PrimaryTextFieldDelegate

extension RegistrationViewController: PrimaryTextFieldDelegate {
    func primaryTextFieldDidTapReturn(_ textField: PrimaryTextField) {
        if textField === firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField === lastNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            registerAction("")
        }
    }
}
