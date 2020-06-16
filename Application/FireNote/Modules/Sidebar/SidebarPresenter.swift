//
//  SidebarPresenter.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

import Cartography
import Foundation
import UIKit

/// A class to present sidebar on controllers
class SidebarPresenter {
    // MARK: - Definitions

    enum Constants {
        static let sidebarLeftInset: CGFloat = 85.0
        static let minVelocityToOpenSidebar: CGFloat = 1200.0
    }

    enum SidebarState {
        case opened, closed
    }

    // MARK: - UI Controls

    private lazy var sidebarFadeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isHidden = true
        view.alpha = 0.0
        return view
    }()

    private var sidebarContainerView = UIView()

    var sidebarController: SidebarViewController?
    private(set) weak var rootViewController: UIViewController!


    // MARK: - Output

    var onDidSelectItem: ((SidebarControllerViewModel.ItemType) -> Void)?
    var onDidLogout: (() -> Void)?

    // MARK: - Properties and variables

    private var sidebarXConstraint: NSLayoutConstraint?

    private var sidebarState: SidebarState = .closed
    var isSidebarEnabled: Bool = false

    // MARK: - Initialization

    func setUpSidebarWith(controller: UIViewController, session: Session) {
        rootViewController = controller

        createSidebarController(with: session)
        configureSidebarContainer()

        let edgeGestureRight = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(sidebarGestureHandler(_:)))
        edgeGestureRight.edges = .right
        controller.view.addGestureRecognizer(edgeGestureRight)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = false
        sidebarFadeView.addGestureRecognizer(tapGesture)
    }

    // MARK: - Sidebar methods

    private func configureSidebarContainer() {
        sidebarFadeView.removeFromSuperview()
        sidebarContainerView.removeFromSuperview()

        rootViewController.view.addSubview(sidebarFadeView)
        rootViewController.view.addSubview(sidebarContainerView)

        constrain(sidebarContainerView, sidebarFadeView, rootViewController.view) { containerView, fadeView, view in
            containerView.top == view.top
            containerView.bottom == view.bottom
            sidebarXConstraint = containerView.left == view.right
            containerView.width == view.width - Constants.sidebarLeftInset

            fadeView.edges == view.edges
        }
    }

    private func createSidebarController(with session: Session) {
        removeSidebarController()

        let controller = SidebarViewController.instantiate(with: SidebarControllerViewModel(session: session))
        controller.delegate = self
        sidebarContainerView.addSubview(controller.view)
        rootViewController.addChild(controller)
        controller.didMove(toParent: rootViewController)

        constrain(controller.view, sidebarContainerView) { controllerView, container in
            controllerView.edges == container.edges
        }

        sidebarContainerView.layoutSubviews()

        sidebarController = controller
    }

    private func removeSidebarController() {
        guard let controller = sidebarController else { return }

        controller.removeFromParent()
        controller.view.removeFromSuperview()
        controller.didMove(toParent: nil)
        controller.view.gestureRecognizers = []

        sidebarController = nil
    }

    func toggleSidebar(shouldExpand: Bool) {
        if shouldExpand {
            sidebarFadeView.isHidden = false
            updateSidebarData()
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }

            self.sidebarXConstraint?.constant = shouldExpand ? -(self.rootViewController.view.frame.width - Constants.sidebarLeftInset) : 0.0
            self.sidebarFadeView.alpha = shouldExpand ? 1.0 : 0.0
            self.rootViewController.view.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if finished {
                self?.sidebarState = self?.sidebarState == .closed ? .opened : .closed
                self?.sidebarFadeView.isHidden = !shouldExpand
            }
        })
    }

    // MARK: - Sidebar Logic methods



    private func updateSidebarData() {
        sidebarController?.updateData()
    }

    // MARK: - UI Callbacks

    @objc private func sidebarGestureHandler(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard isSidebarEnabled else { return }

        switch recognizer.state {
        case .began:
            if sidebarState == .closed {
                updateSidebarData()
                sidebarFadeView.isHidden = false
            } else {
                // cancel gesture
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                toggleSidebar(shouldExpand: false)
            }

        case .changed:
            let maxTranslation = sidebarContainerView.frame.width
            let translation = max(min(recognizer.translation(in: rootViewController.view).x, maxTranslation), -maxTranslation)
            sidebarXConstraint?.constant = translation
            sidebarFadeView.alpha = abs(translation) / maxTranslation

        case .ended:
            let hasMovedGreaterThanHalfway = sidebarContainerView.center.x < rootViewController.view.frame.width
            toggleSidebar(shouldExpand: hasMovedGreaterThanHalfway ||
                recognizer.velocity(in: rootViewController.view).x < -Constants.minVelocityToOpenSidebar)

        default:
            break
        }
    }

    @objc private func tapGestureHandler(_ recognizer: UITapGestureRecognizer) {
        guard isSidebarEnabled else { return }

        if sidebarState == .opened {
            toggleSidebar(shouldExpand: false)
        }
    }
}

// MARK: - SidebarViewControllerDelegate

extension SidebarPresenter: SidebarViewControllerDelegate {
    func sidebarDidClose(_ controller: SidebarViewController) {
        toggleSidebar(shouldExpand: false)
    }

    func sidebarDidSelectItem(_ controller: SidebarViewController, type: SidebarControllerViewModel.ItemType) {
        onDidSelectItem?(type)
    }
}
