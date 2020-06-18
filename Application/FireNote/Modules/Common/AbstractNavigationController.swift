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
    // MARK: - Properties and variables

    let session: Session!

    // MARK: - Initialization

    init(session: Session) {
        self.session = session
        super.init(nibName: nil, bundle: nil)

        let controller = setupRootViewController()
        viewControllers = [controller]

        setupNavigationBarAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("No coder initialization for AbstractNavigationController")
    }

    // MARK: - UI Methods

    /// Sets up the root controller and applies it as root to this navigation controller
    ///
    /// Note: This method must be overriden in any subclass!
    func setupRootViewController() -> UIViewController {
        return UIViewController()
    }

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
        UINavigationBar.appearance().tintColor = R.color.main_normal()
    }
}
