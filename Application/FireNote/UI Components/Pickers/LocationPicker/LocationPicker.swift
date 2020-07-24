//
//  LocationPicker.swift
//  FireNote
//
//  Created by Denis Kovalev on 21.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import GoogleMaps
import GooglePlaces
import UIKit

/// A protocol for LocationPicker operations
protocol LocationPickerDelegate: AnyObject {
    /// Called, when the location was selected
    func locationPicker(_ picker: LocationPicker, didSelectLocation item: LocationItem)

    /// Called, when the cancel button was pressed
    func locationPickerDidCancel(_ picker: LocationPicker)
}

/// A class to present the location picker view on controller and handle the events
class LocationPicker: NSObject {
    // MARK: - Definitions

    enum Constants {
        /// Time of present/dismiss animation
        static let animationTime: TimeInterval = 0.3

        /// Defines the picker view's width relative to parent view (width = parent.width * ratio)
        static let widthRatio: CGFloat = 0.8

        /// Defines the picker view's height relative to parent view (height = parent.height * ratio)
        static let heightRatio: CGFloat = 0.7
    }

    // MARK: - UI Controls

    private lazy var pickerView: LocationPickerView = {
        let view = LocationPickerView()
        view.delegate = self
        return view
    }()

    private lazy var fadeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()

    // MARK: - Properties and variables

    private weak var presentationController: UIViewController?

    private lazy var locationManager: LocationManager = {
        let manager = LocationManager()
        manager.delegate = self
        return manager
    }()

    private weak var delegate: LocationPickerDelegate?

    // MARK: - Initializaion

    init(presentationController: UIViewController, delegate: LocationPickerDelegate) {
        self.presentationController = presentationController
        self.delegate = delegate

        super.init()
    }

    // MARK: - UI Methods

    /// Presents the picker view on presentation controller with animation
    func present(with location: LocationItem? = nil) {
        pickerView.configureWith(location)

        if let view = presentationController?.view {
            pickerView.alpha = 0.0
            fadeView.alpha = 0.0
            view.addSubview(fadeView)
            view.addSubview(pickerView)

            let width = view.frame.width * Constants.widthRatio
            let height = view.frame.height * Constants.heightRatio
            pickerView.frame.size = CGSize(width: width, height: height)
            pickerView.center.x = view.frame.width / 2
            pickerView.frame.origin.y = view.frame.maxY

            fadeView.frame = CGRect(origin: .zero, size: view.frame.size)
            movePicker(shouldOpen: true)
        }
    }

    /// Dismisses the picker view with animation
    func dismiss() {
        if presentationController != nil {
            movePicker(shouldOpen: false) { [weak self] in
                self?.pickerView.removeFromSuperview()
                self?.fadeView.removeFromSuperview()
            }
        }
    }

    private func movePicker(shouldOpen: Bool, completion: (() -> Void)? = nil) {
        if let parentView = pickerView.superview {
            UIView.animate(withDuration: Constants.animationTime, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
                if shouldOpen {
                    self?.pickerView.center.y = parentView.frame.height / 2
                    self?.pickerView.alpha = 1.0
                    self?.fadeView.alpha = 1.0
                } else {
                    self?.pickerView.frame.origin.y = parentView.frame.maxY
                    self?.pickerView.alpha = 0.0
                    self?.fadeView.alpha = 0.0
                }
            }, completion: { finished in
                if finished {
                    completion?()
                }
            })
        }
    }

    private func showError(message: String) {
        if let controller = presentationController {
            AlertPresenter.presentErrorAlert(message: message, target: controller)
        }
    }
}

// MARK: - LocationPickerViewDelegate

extension LocationPicker: LocationPickerViewDelegate {
    func locationPickerViewDidTapLocate(_ view: LocationPickerView) {
        locationManager.requestUserLocation()
    }

    func locationPickerViewDidClose(_ view: LocationPickerView) {
        delegate?.locationPickerDidCancel(self)
    }

    func locationPickerView(_ view: LocationPickerView, didSelectLocation location: CLLocationCoordinate2D) {
        locationManager.fetchAddressFrom(location) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(address):
                self.delegate?.locationPicker(self, didSelectLocation: LocationItem(coordinate: location, formattedAddress: address))
            case let .failure(error):
                self.showError(message: error.localizedDescription)
            }
        }
    }

    func locationPickerView(_ view: LocationPickerView, didSelectPlaceWithId placeId: String) {
        if !placeId.isEmpty {
            locationManager.fetchPlaceInfoFor(placeId: placeId) { [weak self] result in
                switch result {
                case let .success(place):
                    self?.pickerView.updateMapCenterWith(coordinate: place.coordinate)
                case let .failure(error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }

    func locationPickerView(_ view: LocationPickerView, didUpdateSearchContent text: String) {
        if !text.isEmpty {
            locationManager.fetchSuggestionsFor(text: text) { [weak self] result in
                switch result {
                case let .success(suggestions):
                    self?.pickerView.updateSuggestionsWith(suggestions: suggestions.compactMap { LocationSuggestionItem($0) })
                case let .failure(error):
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - LocationManagerDelegate

extension LocationPicker: LocationManagerDelegate {
    func locationManager(_ manager: LocationManager, didUpdateUserLocation result: Result<CLLocationCoordinate2D, APIError>) {
        switch result {
        case let .success(coordinate):
            pickerView.updateMapCenterWith(coordinate: coordinate)
        case let .failure(error):
            showError(message: error.localizedDescription)
        }
    }
}
