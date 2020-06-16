//
//  HUDPresenter.swift
//  FireNote
//
//  Created by Denis Kovalev on 16.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

class HUDPresenter {
    private static let hudView = HUDLoaderView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))

    private static let fadeView: UIView = {
        let view = UIView()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.1)

        let recognizer = UITapGestureRecognizer(target: view, action: nil)
        recognizer.cancelsTouchesInView = true
        view.addGestureRecognizer(recognizer)
        return view
    }()

    class func showHUD() {
        if let window = UIApplication.shared.windows.first {
            window.addSubview(fadeView)
            fadeView.frame = window.frame

            window.addSubview(hudView)
            hudView.frame.origin = CGPoint(x: window.frame.width / 2 - hudView.frame.width / 2,
                                           y: window.frame.height / 2 - hudView.frame.height / 2)
        }
    }

    class func hideHUD() {
        fadeView.removeFromSuperview()
        hudView.removeFromSuperview()
    }
}
