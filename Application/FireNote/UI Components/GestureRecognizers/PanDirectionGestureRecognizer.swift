//
//  PanDirectionGestureRecognizer.swift
//  FireNote
//
//  Created by Denis Kovalev on 01.09.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// Represents the pan gesture, but sensitive only for horizontal/vertical moves
class PanDirectionGestureRecognizer: UIPanGestureRecognizer {

    // MARK: - Definitions

    enum Direction {
        case vertical
        case horizontal
    }

    // MARK: - Properties and variables
    let direction: Direction

    // MARK: - Initialization

    init(direction: Direction, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    // MARK: - Overriden methods

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }

}
