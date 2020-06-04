//
//  UIColor+Extensions.swift
//  FireNote
//
//  Created by Denis Kovalev on 04.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

extension UIColor {
    /// Gets the random color with minimum brightness value (from 0.0 to 1.0)
    class func randomColorWith(minimumBrightness: CGFloat) -> UIColor {
        return UIColor(red: CGFloat.random(in: minimumBrightness ... 1.0),
                       green: CGFloat.random(in: minimumBrightness ... 1.0),
                       blue: CGFloat.random(in: minimumBrightness ... 1.0),
                       alpha: 1.0)
    }

    /// Merges two colors as mean value of each two color components
    func mergeWith(_ color: UIColor) -> UIColor {
        var red1: CGFloat = 0.0, green1: CGFloat = 0.0, blue1: CGFloat = 0.0, alpha1: CGFloat = 0.0
        var red2: CGFloat = 0.0, green2: CGFloat = 0.0, blue2: CGFloat = 0.0, alpha2: CGFloat = 0.0
        color.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        return UIColor(red: (red1 + red2) / 2, green: (green1 + green2) / 2, blue: (blue1 + blue2) / 2, alpha: 1.0)
    }
}
