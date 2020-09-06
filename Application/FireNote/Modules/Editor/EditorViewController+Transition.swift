//
//  EditorViewController+Transition.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// An extension to implement the pop-up transition for gallery controller
extension EditorViewController {

    func presentWithPopUp(controller: UIViewController) {
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .fullScreen

        present(controller, animated: true, completion: nil)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension EditorViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard presenting is EditorViewController,
            let originFrame = selectedImageRect,
            let originImageIndex = selectedImageIndex
            else { return nil }

        presentingAnimator = PopImagePresentingAnimator(originImageIndex: selectedImageIndex, originFrame: selectedImageRect)
        return presentingAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        guard let galleryController = dismissed as? GalleryViewController else { return nil }

        animator = PopImageDismissingAnimator(finalImageIndex: <#T##Int#>, finalFrame: <#T##CGRect?#>)
        return animator
    }
}

