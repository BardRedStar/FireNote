//
//  AbstractNavigationController.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A superclass for abstract navigation controller, which provides the base functionality of navcontroller
class AbstractNavigationController: UINavigationController {
    // MARK: - Initialization

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setupNavigationBarAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNavigationBarAppearance()
    }

    // MARK: - UI Methods

    func hideNavigationBar() {
        navigationBar.isHidden = true
    }

    func showNavigationBar() {
        navigationBar.isHidden = false
    }

    func makeNavigationBarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        view.backgroundColor = .clear
    }

    /// Sets up the navbar appearance.
    ///
    /// Note: Override this method to set up navbar for your navigation flow.
    func setupNavigationBarAppearance() {
        showNavigationBar()
    }
}
