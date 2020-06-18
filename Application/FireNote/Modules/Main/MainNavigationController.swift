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
    // MARK: - Output

    var onLogout: (() -> Void)?

    // MARK: - Properties and variabels

    private lazy var sidebarPresenter: SidebarPresenter = {
        let sidebarPresenter = SidebarPresenter()
        sidebarPresenter.isSidebarEnabled = true
        sidebarPresenter.onDidSelectItem = { [weak self] item in
            self?.route(with: item)
        }

        sidebarPresenter.onDidLogout = { [weak self] in
            self?.onLogout?()
        }
        return sidebarPresenter
    }()

    // MARK: - Initialization

    override init(session: Session) {
        super.init(session: session)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setupRootViewController() -> UIViewController {
        let controller = MainViewController.instantiate(viewModel: MainControllerViewModel(session: session))
        sidebarPresenter.setUpSidebarWith(controller: controller, session: session)
        return controller
    }

    // MARK: - UI Methods

    override func setupNavigationBarAppearance() {
        super.setupNavigationBarAppearance()
        makeNavigationBarTransparent()
    }

    // MARK: - Routing

    private func route(with item: SidebarControllerViewModel.Item) {
        switch item {
        default: return
        }
    }
}
