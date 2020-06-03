//
//  MainNavigationController.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class to coordinate the auth flow navigation
class MainNavigationController: AbstractNavigationController {
    // MARK: - Initialization

    override func setupRootViewController() -> UIViewController {
        let controller = MainViewController.instantiate(viewModel: MainControllerViewModel(session: session))

        return controller
    }

    override func setupNavigationBarAppearance() {
        super.setupNavigationBarAppearance()
        makeNavigationBarTransparent()
    }

    // MARK: - Routing
}
