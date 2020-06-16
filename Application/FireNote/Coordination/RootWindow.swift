//
//  AppCoordinator.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation
import UIKit

class RootWindow: UIWindow {
    var session: Session!

    func start(_ deeplink: DeepLink?) {
        runSplash()
    }

    private func runSplash() {
        let controller = SplashViewController.instantiate(viewModel: SplashControllerViewModel(session: session))

        controller.onFinish = { [weak self] in
            if self?.session.isAuthorized == true {
                self?.runMain()
            } else {
                self?.runAuth()
            }
        }
        rootViewController = controller
    }

    private func runAuth() {
        let controller = AuthNavigationController(session: session)

        controller.onLogin = { [weak self] in
            self?.runMain()
        }
        rootViewController = controller
    }

    private func runMain() {
        let controller = MainNavigationController(session: session)

        rootViewController = controller
    }
}
