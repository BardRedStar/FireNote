//
//  MainViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Reusable
import UIKit

class MainViewController: AbstractViewController, StoryboardBased {
    // MARK: - Properties and variables

    private var viewModel: MainControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: MainControllerViewModel) -> MainViewController {
        let controller = MainViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
