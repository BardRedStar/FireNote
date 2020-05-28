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
    // MARK: - Output

    var onFinish: (() -> Void)?

    // MARK: - Properties and variables

    var viewModel: LoginControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: LoginControllerViewModel) -> LoginViewController {
        let controller = LoginViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UI Methods

    private func auth() {}
}
