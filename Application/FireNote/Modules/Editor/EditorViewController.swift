//
//  EditorViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 19.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Aztec
import Reusable
import UIKit

/// A controller class for note editor screen
class EditorViewController: AbstractViewController, StoryboardBased {
    // MARK: - Definitions

    // MARK: - Outlets

    // MARK: - UI Controls

    // MARK: - Output

    // MARK: - Properties and variables

    private var viewModel: EditorControllerViewModel!

    // MARK: - UI Lifecycle

    class func instantiate(viewModel: EditorControllerViewModel) -> EditorViewController {
        let controller = EditorViewController.instantiate()
        controller.viewModel = viewModel
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
