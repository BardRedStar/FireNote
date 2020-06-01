//
//  AbstractViewController.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A base class to operate with the common things for all controllers
class AbstractViewController: UIViewController {
    // MARK: - Output

    var onBack: (() -> Void)?

    // MARK: - UI Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"), style: .plain, target: self, action: #selector(backAction))
        navigationItem.backBarButtonItem = backButton
    }

    // MARK: - UI Callbacks

    @objc private func backAction(_ sender: UIBarButtonItem) {
        onBack?()
    }
}
