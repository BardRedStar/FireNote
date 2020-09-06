//
//  PopImageDismissingAnimator.swift
//  FireNote
//
//  Created by Denis Kovalev on 02.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A class, which performs the pop-up dismissing animation with image
class PopImageDismissingAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Definitions

    enum Constants {
        /// Duration of animation
        static let duration: TimeInterval = 0.5
    }

    // MARK: - Properties and variables

    private let finalImageIndex: Int
    private let finalFrame: CGRect?

    // MARK: - Initialization

    init(finalImageIndex: Int, finalFrame: CGRect?) {
        self.finalImageIndex = finalImageIndex
        self.finalFrame = finalFrame
        super.init()
    }

    // MARK: - Animator methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toVC = transitionContext.viewController(forKey: .to) as? EditorViewController,
            let toCell = toVC.galleryView.collectionView.cellForItem(at: IndexPath(item: finalImageIndex, section: 0)),
            let fromVC = transitionContext.viewController(forKey: .from) as? GalleryViewController,
            let fromCell = fromVC.galleryView.collectionView.cellForItem(at: IndexPath(item: finalImageIndex,
                                                                                       section: 0)) as? GalleryViewCollectionViewCell,
            let finalFrame = finalFrame
            else {
                transitionContext.completeTransition(true)
                return
        }

        let containerView = transitionContext.containerView

        // Determine original and final frames
        let size = fromCell.imageView.frame.size
        let convertedRect = fromCell.imageView.convert(fromCell.imageView.bounds, to: containerView)
        let originFrame = CGRect(origin: convertedRect.origin, size: size)

        let viewToAnimate = UIImageView(frame: originFrame)
        viewToAnimate.center = CGPoint(x: convertedRect.midX, y: convertedRect.midY)
        viewToAnimate.image = fromCell.imageView.image
        viewToAnimate.contentMode = .scaleAspectFill
        viewToAnimate.clipsToBounds = true

        containerView.addSubview(viewToAnimate)

        toCell.isHidden = true
        fromVC.view.isHidden = true

        // Animate size and position
        UIView.animate(withDuration: Constants.duration, animations: {
            viewToAnimate.frame.size.width = finalFrame.width
            viewToAnimate.frame.size.height = finalFrame.height
            viewToAnimate.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
        }, completion: { _ in
            toCell.isHidden = false
            viewToAnimate.removeFromSuperview()
            transitionContext.completeTransition(true)
        })

    }
}
