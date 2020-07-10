//
//  CGPoint+Extensions.swift
//  FireNote
//
//  Created by Denis Kovalev on 26.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
