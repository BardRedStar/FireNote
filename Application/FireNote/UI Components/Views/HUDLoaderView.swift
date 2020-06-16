//
//  HUDLoaderView.swift
//  FireNote
//
//  Created by Denis Kovalev on 04.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A view, which represents the loader item in loading HUD
class HUDLoaderView: SettableView {
    enum Constants {
        static let circleSide: CGFloat = 16.0
    }

    static var shared = HUDLoaderView()

    private var circleViews: [UIView] = []

    override func setup() {
        super.setup()

        backgroundColor = .clear

        (0 ... 3).forEach { index in
            circleViews.append(createCircleView())
            addSubview(circleViews[index])
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let topInset = frame.size.height / 2 - CGFloat(Constants.circleSide) / 2
        let leftInset = frame.size.width / 2 - CGFloat(Constants.circleSide) / 2
        circleViews.forEach {
            $0.alpha = 1.0
            $0.layer.removeAllAnimations()
            $0.frame.origin = CGPoint(x: leftInset, y: topInset)
        }

        // Begin the animation
        splitCircles()
    }

    private func splitCircles() {
        let interval = (frame.size.width - Constants.circleSide * CGFloat(circleViews.count)) / CGFloat(circleViews.count - 1)
            + Constants.circleSide
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.circleViews.enumerated().forEach {
                $1.frame.origin.x = interval * CGFloat($0)
                $1.backgroundColor = UIColor.randomColorWith(minimumBrightness: 0.0)
            }
        }, completion: { [weak self] finished in
            if finished {
                self?.mergeCircles()
            }
        })
    }

    private func mergeCircles() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }

            self.mergeTwoCircles(self.circleViews[0], self.circleViews[1])
            self.mergeTwoCircles(self.circleViews[2], self.circleViews[3])

        }, completion: { [weak self] finished in
            if finished {
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    guard let self = self else { return }
                    self.mergeTwoCircles(self.circleViews[1], self.circleViews[3])
                }, completion: { [weak self] finished in
                    if finished {
                        self?.layoutSubviews()
                    }
                })
            }
        })
    }

    private func mergeTwoCircles(_ circle1: UIView, _ circle2: UIView) {
        let center = (circle1.frame.origin.x + circle2.frame.origin.x) / 2
        circle1.frame.origin.x = center
        circle2.frame.origin.x = center
        circle1.alpha = 0.0
        circle2.backgroundColor = circle1.backgroundColor?.mergeWith(circle2.backgroundColor ?? .white)
    }

    private func createCircleView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.circleSide, height: Constants.circleSide))
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }
}
