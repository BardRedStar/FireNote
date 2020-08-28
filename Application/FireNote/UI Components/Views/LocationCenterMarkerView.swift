//
//  LocationCenterMarkerView.swift
//  FireNote
//
//  Created by Denis Kovalev on 27.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A view class, which draws the marker for maps
class LocationCenterMarkerView: SettableView {
    // MARK: - Definitions

    /// Represents the moving direction for marker image
    enum MoveDirection {
        case up, down
    }

    // MARK: - UI Components

    private lazy var markerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "ic_pin")
        imageView.tintColor = R.color.main_normal()
        return imageView
    }()

    private lazy var markerPointView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.shadow()
        return view
    }()

    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.shadow()
        view.alpha = 0.15
        return view
    }()

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        clipsToBounds = false
        isUserInteractionEnabled = false

        addSubview(shadowView)
        addSubview(markerPointView)
        addSubview(markerImageView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        markerImageView.frame = bounds

        let markerPointSide = bounds.width * 1.5 / 20
        markerPointView.frame = CGRect(x: bounds.midX - markerPointSide / 2, y: bounds.maxY - markerPointSide / 2,
                                       width: markerPointSide, height: markerPointSide)
        markerPointView.layer.cornerRadius = markerPointSide / 2

        let shadowSide = bounds.width / 1.5
        shadowView.frame.size = CGSize(width: shadowSide, height: shadowSide / 1.5)
        shadowView.frame.origin = CGPoint(x: bounds.midX - shadowView.frame.width / 2, y: bounds.maxY - shadowView.frame.height / 2)
        shadowView.layer.cornerRadius = shadowSide / 2
        shadowView.dropShadow(color: .black, opacity: 1.0, offset: CGSize(width: 0, height: 0.5), radius: 15)
    }

    // MARK: - UI Methods

    /// Moves the marker image toward the passed direction
    func moveWith(direction: MoveDirection) {
        /// Delay is here to avoid the animation collision with Google Maps MapView camera
        delay(0.01, completion: { [weak self] in
            self?.performAnimationFor(direction: direction)
        })
    }

    /// Performs the animation with direction
    private func performAnimationFor(direction: MoveDirection) {
        markerImageView.layer.removeAllAnimations()
        shadowView.layer.removeAllAnimations()
        markerPointView.layer.removeAllAnimations()

        UIView.animate(withDuration: 0.15, delay: 0, animations: { [weak self] in
            guard let self = self else { return }

            self.markerImageView.frame.origin.y = direction == .up ? -20 : 0
            self.markerPointView.alpha = direction == .up ? 0.5 : 0.0
            self.shadowView.alpha = direction == .up ? 0.05 : 0.15
        }, completion: { [weak self] finished in
            if finished, direction == .up {
                self?.startFloating()
            }
        })
    }

    /// Initiates the repeating animation for idle (floating a bit up and down)
    private func startFloating() {
        UIView.animate(withDuration: 0.7, delay: 0.0, options: [.repeat, .autoreverse, .curveLinear], animations: { [weak self] in
            self?.markerImageView.frame.origin.y = -10
            self?.shadowView.alpha = 0.1
            self?.markerPointView.alpha = 0.85
        })
    }
}
