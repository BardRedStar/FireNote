//
//  PopImagePresentingAnimator.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class, which performs the pop-up presenting animation with image
class PopImagePresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Definititons

    enum Constants {
        /// Animation duration
        static let duration: TimeInterval = 0.5
    }

    // MARK: - Properties and variables

    private let originImageIndex: Int
    private let originFrame: CGRect

    // MARK: - Initialization

    init(originImageIndex: Int, originFrame: CGRect) {
        self.originImageIndex = originImageIndex
        self.originFrame = originFrame
        super.init()
    }

    // MARK: - Animator methods

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toView = transitionContext.view(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) as? EditorViewController,
            let fromView = fromVC.galleryView.collectionView.cellForItem(at: IndexPath(row: originImageIndex,
                                                                                       section: 0)) as? EditorGalleryCollectionViewCell
            else {
                transitionContext.completeTransition(true)
                return
        }

        let finalFrame = toView.frame

        let viewToAnimate = UIImageView(frame: originFrame)
        viewToAnimate.image = fromView.imageView.image
        viewToAnimate.contentMode = .scaleAspectFill
        viewToAnimate.clipsToBounds = true
        fromView.imageView.isHidden = true

        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(viewToAnimate)

        toView.isHidden = true

        // Determine the final image height based on final frame width and image aspect ratio
        let imageAspectRatio = viewToAnimate.image!.size.width / viewToAnimate.image!.size.height
        let finalImageHeight = finalFrame.width / imageAspectRatio

        // Animate size and position
        UIView.animate(withDuration: Constants.duration, animations: {
            viewToAnimate.frame.size.width = finalFrame.width
            viewToAnimate.frame.size.height = finalImageHeight
            viewToAnimate.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion:{ _ in
            toView.isHidden = false
            fromView.imageView.isHidden = false
            viewToAnimate.removeFromSuperview()
            transitionContext.completeTransition(true)
        })

    }
}
