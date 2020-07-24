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

        textField.font = R.font.baloo2Regular(size: 15.0)
        textField.textColor = R.color.text_primary()

        textField.layer.borderColor = R.color.main_normal()?.cgColor
        textField.layer.borderWidth = 1
        textField.dropShadow(opacity: 0.25, radius: 2)

        return textField
    }()

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ic_close"), for: .normal)
        button.imageView?.tintColor = R.color.main_normal()
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

        tableView.rowHeight = Constants.suggestionRowHeight
        tableView.isHidden = true
        tableView.separatorStyle = .none
        tableView.register(cellType: LocationSuggestionTableViewCell.self)
        return tableView
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

        addSubview(mapView)
        addSubview(locationButton)
        addSubview(searchField)
        addSubview(closeButton)
        addSubview(selectButton)
        addSubview(tableView)

        constrain(mapView, locationButton, closeButton, selectButton, searchField,
                  tableView, self) { map, locationButton, closeButton, selectButton, field, table, view in

            closeButton.top == view.top + 5
            closeButton.right == view.right - 5
            closeButton.height == 28
            closeButton.width == 28

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
            tableViewHeightConstraint = table.height == Constants.suggestionRowHeight * 4
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
        }
    }

    /// Moves the map center to the coordinates
    func updateMapCenterWith(coordinate: CLLocationCoordinate2D) {
        mapView.animate(toLocation: coordinate)
    }

    private func toggleSuggestionsTable(shouldOpen: Bool) {
        tableView.isHidden = false
        UIView.animate(withDuration: Constants.suggestionsToggleTime, delay: 0.0, options: .curveEaseInOut, animations: { [weak self] in
            self?.tableViewHeightConstraint.constant = shouldOpen ? Constants.suggestionRowHeight * 4 : 0.0
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
}

// MARK: - GMSMapViewDelegate

extension LocationPickerView: GMSMapViewDelegate {}

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
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension LocationPickerView: UITableViewDataSource, UITableViewDelegate {
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
