//
//  AlertPresenter.swift
//  FireNote
//
//  Created by Denis Kovalev on 03.06.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

/// A helper class for presenting alert dialogs on view controllers
class AlertPresenter {
    /// Presents the alert dialog on target view controller with specified title, body message and actions
    class func presentAlertWith(title: String? = nil, message: String? = nil, actions: [UIAlertAction] = [], target: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        target.present(alertController, animated: true, completion: nil)
    }

    /// Presents simple alert dialog with title, body message and one button
    class func presentSimpleAlert(title: String? = nil, message: String? = nil, target: UIViewController, buttonText: String = "OK",
                                  buttonStyle: UIAlertAction.Style = .default, buttonAction: (() -> Void)? = nil) {
        let action = UIAlertAction(title: buttonText, style: buttonStyle, handler: { _ -> Void in buttonAction?() })
        presentAlertWith(title: title, message: message, actions: [action], target: target)
    }

    /// Presents the alert dialog with "Error" title, body message and the only OK button
    class func presentErrorAlert(title: String = "Error", message: String, target: UIViewController, buttonAction: (() -> Void)? = nil) {
        presentSimpleAlert(title: title, message: message, target: target, buttonAction: buttonAction)
    }
}
