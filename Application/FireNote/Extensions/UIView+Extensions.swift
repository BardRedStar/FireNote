//
//  UIView+Extensions.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

extension UIView {
    /// Drops shadow to the view's bounds
    func dropShadow(color: UIColor = .black, opacity: Float = 0.3, offset: CGSize = .zero, radius: CGFloat = 3.5) {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowPath = shadowPath.cgPath
    }
}
