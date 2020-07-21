//
//  LocationPicker.swift
//  FireNote
//
//  Created by Denis Kovalev on 21.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import UIKit

protocol LocationPickerDelegate: AnyObject {
}

class LocationPicker: NSObject {

    // MARK: - Properties and variables

    private weak var presentationController: UIViewController?
    private weak var delegate: LocationPickerDelegate?

    // MARK: - Initializaion

    init(presentationController: UIViewController, delegate: LocationPickerDelegate) {
        self.presentationController = presentationController
        self.delegate = delegate

        super.init()

    }

    // MARK: - UI Methods

    func present() {

    }
}
