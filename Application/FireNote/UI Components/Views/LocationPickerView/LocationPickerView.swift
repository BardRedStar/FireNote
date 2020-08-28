//
//  LocationPickerView.swift
//  FireNote
//
//  Created by Denis Kovalev on 21.07.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Cartography
import GoogleMaps
import UIKit

/// A protocol for LocationPickerView actions
protocol LocationPickerViewDelegate: AnyObject {
    /// Called, when the locate button was tapped
    func locationPickerViewDidTapLocate(_ view: LocationPickerView)
    /// Called, when the close button was tapped
    func locationPickerViewDidClose(_ view: LocationPickerView)
    /// Called, when the location coordinates were selected
    func locationPickerView(_ view: LocationPickerView, didSelectLocation location: CLLocationCoordinate2D)
    /// Called, when the search content was updated
    func locationPickerView(_ view: LocationPickerView, didUpdateSearchContent text: String)
    /// Called, when the suggestion was selected from table view
    func locationPickerView(_ view: LocationPickerView, didSelectPlaceWithId placeId: String)
    /// Called, when the search field's return key was tapped, and text isn't empty
    func locationPickerView(_ view: LocationPickerView, didSearchAddress address: String)
}

/// A view to pick the location from the map and your geolocation
class LocationPickerView: SettableView {
    // MARK: - Definitions

    enum Constants {
        /// A time interval to consider user stopped typing.
        static let stopTypingTimeInterval: TimeInterval = 0.6

        /// Row height value in suggestions table view
        static let suggestionRowHeight: CGFloat = 30.0

        /// Time interval (in seconds) to toggle the suggestions table
        static let suggestionsToggleTime: TimeInterval = 0.2
    }

    // MARK: - UI Controls

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = R.font.baloo2Medium(size: 18)
        label.text = "Select Location"
        label.textColor = R.color.text_primary()
        label.numberOfLines = 1
        return label
    }()

    private lazy var mapView: GMSMapView = {
        let mapView = GMSMapView()
        mapView.delegate = self
        return mapView
    }()

    private lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_location"), for: .normal)
        button.imageView?.tintColor = R.color.main_normal()
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        button.layer.borderColor = R.color.main_normal()?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 4

        button.addTarget(self, action: #selector(locationAction), for: .touchUpInside)
        return button
    }()

    private lazy var searchField: SearchTextField = {
        let textField = SearchTextField()
        textField.placeholder = "Find your location"
        textField.delegate = self
        textField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)

        textField.font = R.font.baloo2Regular(size: 14.0)
        textField.textColor = R.color.text_primary()

        textField.layer.borderColor = R.color.main_normal()?.cgColor
        textField.layer.borderWidth = 1
        textField.dropShadow(opacity: 0.25, radius: 2)

        textField.autocorrectionType = .no
        textField.returnKeyType = .search

        return textField
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        button.imageView?.tintColor = R.color.gray_dark()
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        return button
    }()

    private lazy var selectButton: PrimaryButton = {
        let button = PrimaryButton()
        button.setTitle("Select Location", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.sizeToFit()
        button.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.isHidden = true
        tableView.separatorStyle = .none

        tableView.layer.cornerRadius = 6
        tableView.layer.borderColor = R.color.main_normal()?.cgColor
        tableView.layer.borderWidth = 1

        tableView.register(cellType: LocationSuggestionTableViewCell.self)
        return tableView
    }()

    private lazy var centerMarker: LocationCenterMarkerView = {
        let markerView = LocationCenterMarkerView()
        return markerView
    }()

    /// Constraints

    private var tableViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties and variables

    weak var delegate: LocationPickerViewDelegate?

    private var typingTimer: Timer?

    private var suggestions: [LocationSuggestionItem] = []

    /// Defines, whether suggestions are enabled for now or not
    var isSuggestionsEnabled: Bool {
        return searchField.isFirstResponder
    }

    // MARK: - UI Lifecycle

    override func setup() {
        super.setup()

        layer.cornerRadius = 14
        backgroundColor = .white

        addSubview(titleLabel)
        addSubview(mapView)
        addSubview(locationButton)
        addSubview(searchField)
        addSubview(closeButton)
        addSubview(selectButton)
        addSubview(centerMarker)
        addSubview(tableView)

        constrain(titleLabel, mapView, locationButton, closeButton, selectButton, searchField,
                  tableView, centerMarker, self) { title, map, locationButton, closeButton, selectButton, field, table, marker, view in

            closeButton.top == view.top + 5
            closeButton.right == view.right - 5
            closeButton.height == 28
            closeButton.width == 28

            title.centerX == view.centerX
            title.top == view.top + 5

            locationButton.top == closeButton.bottom + 10
            locationButton.right == view.right - 10
            locationButton.height == 28
            locationButton.width == 28

            field.left == view.left + 10
            field.right == locationButton.left - 10
            field.centerY == locationButton.centerY
            field.height == locationButton.height

            map.top == field.bottom + 10
            map.left == view.left + 10
            map.right == view.right - 10

            selectButton.top == map.bottom + 10
            selectButton.left >= view.left + 10
            selectButton.right <= view.right - 10
            selectButton.bottom == view.bottom - 10
            selectButton.height == 35
            selectButton.centerX == view.centerX

            table.top == field.bottom + 5
            table.left == field.left
            table.right == field.right
            table.width == field.width
            tableViewHeightConstraint = table.height == Constants.suggestionRowHeight * 4

            marker.bottom == map.centerY
            marker.centerX == map.centerX
            marker.width == 30
            marker.height == 60
        }
    }

    // MARK: - UI Methods

    /// Configures view with model
    func configureWith(_ model: LocationItem?) {
        searchField.text = model?.formattedAddress ?? ""
        mapView.animate(toLocation: model?.coordinate ?? CLLocationCoordinate2D())
    }

    /// Updates the suggestions list in table
    func updateSuggestionsWith(suggestions: [LocationSuggestionItem]) {
        if !suggestions.isEmpty {
            self.suggestions = suggestions

            if searchField.isFirstResponder {
                tableView.reloadData()
                toggleSuggestionsTable(shouldOpen: true)
            }
        } else {
            toggleSuggestionsTable(shouldOpen: false)
        }
    }

    /// Moves the map center to the coordinates
    func updateMapCenterWith(coordinate: CLLocationCoordinate2D) {
        mapView.animate(toZoom: 13.0)
        mapView.animate(toLocation: coordinate)
    }

    /// Updates the location button enabled state
    func updateLocationButtonState(isEnabled: Bool) {
        locationButton.isEnabled = isEnabled

        let color = isEnabled ? R.color.main_normal() : R.color.main_disabled()
        locationButton.imageView?.tintColor = color
        locationButton.layer.borderColor = color?.cgColor
    }

    private func toggleSuggestionsTable(shouldOpen: Bool) {
        tableView.isHidden = false

        let estimatedHeight = shouldOpen ? suggestions.reduce(0) {
            $0 + LocationSuggestionTableViewCell.contentHeightFor($1.address, frameWidth: tableView.frame.width)
        } : 0.0

        UIView.animate(withDuration: Constants.suggestionsToggleTime, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.tableViewHeightConstraint.constant = estimatedHeight
            self?.layoutIfNeeded()
        }, completion: { [weak self] finished in
            if finished, !shouldOpen {
                self?.tableView.isHidden = true
            }
        })
    }

    // MARK: - UI Callbacks

    @objc private func locationAction(_ sender: UIButton) {
        delegate?.locationPickerViewDidTapLocate(self)
    }

    @objc private func closeAction(_ sender: UIButton) {
        delegate?.locationPickerViewDidClose(self)
    }

    @objc private func selectAction(_ sender: UIButton) {
        delegate?.locationPickerView(self, didSelectLocation: mapView.camera.target)
    }

    @objc private func searchFieldDidChange(_ sender: UITextField) {
        guard let text = sender.text, !text.isEmpty else {
            toggleSuggestionsTable(shouldOpen: false)
            return
        }
    }
}

// MARK: - GMSMapViewDelegate

extension LocationPickerView: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            centerMarker.moveWith(direction: .up)
        }
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        centerMarker.moveWith(direction: .down)
    }
}

// MARK: - Timer

extension LocationPickerView {
    private func updateTimer() {
        typingTimer?.invalidate()
        typingTimer = Timer.scheduledTimer(timeInterval: Constants.stopTypingTimeInterval, target: self,
                                           selector: #selector(stopTypingAction), userInfo: nil, repeats: false)
    }

    @objc private func stopTypingAction(_ sender: Any) {
        typingTimer?.invalidate()
        typingTimer = nil

        delegate?.locationPickerView(self, didUpdateSearchContent: searchField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension LocationPickerView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        updateTimer()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        toggleSuggestionsTable(shouldOpen: false)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            textField.resignFirstResponder()
            delegate?.locationPickerView(self, didSearchAddress: text)
        }
        return true
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension LocationPickerView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LocationSuggestionTableViewCell.contentHeightFor(suggestions[indexPath.row].address, frameWidth: tableView.frame.width)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LocationSuggestionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configureWith(title: suggestions[indexPath.row].address)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        toggleSuggestionsTable(shouldOpen: false)
        searchField.text = suggestions[indexPath.row].address
        delegate?.locationPickerView(self, didSelectPlaceWithId: suggestions[indexPath.row].placeId)
    }
}
