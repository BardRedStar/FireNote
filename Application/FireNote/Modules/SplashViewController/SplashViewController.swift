//
import Reusable
//  SplashViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//
import UIKit

/// A controller class for splash screen
class SplashViewController: UIViewController, StoryboardBased {
    // MARK: - Output

    var onFinish: (() -> Void)?

    // MARK: - Properties and variables

    var viewModel: SplashControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: SplashControllerViewModel) -> SplashViewController {
        let controller = SplashViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delay(2.0, completion: { [weak self] in
            self?.onFinish?()
        })
    }

    // MARK: - UI Methods
}
