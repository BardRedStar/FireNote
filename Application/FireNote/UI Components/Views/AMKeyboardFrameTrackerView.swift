//
//  AMKeyboardFrameTracker.swift
//  AMKeyboardFrameTracker
//
//  Created by Amr Mohamed on 1/16/19.
//  Copyright © 2019 Amr Mohamed. All rights reserved.
//
import UIKit

public protocol AMKeyboardFrameTrackerDelegate: AnyObject {
    func keyboardFrameDidChange(with frame: CGRect)
}

public class AMKeyboardFrameTrackerView: UIView {
    /// Set your self as the delegate
    /// if you want to observe keyboard frame changes in a delegate style
    public weak var delegate: AMKeyboardFrameTrackerDelegate?

    /// This closure will be called everytime a keyboard frame change
    public var onKeyboardFrameDidChange: ((_ frame: CGRect) -> Void)?

    /// Used to only add the observer once
    private var didAddObserver = false

    /// The current keyboard frame
    /// This could be nil if there is no inputAccessoryView attached to the keyboard
    public var currentKeyboardFrame: CGRect? {
        return superview?.frame
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /// If you are not to using a height constraint
    /// for this view make sure to pass in the extra height you want above the keyboard
    /// the height is used for the keyboard to start
    /// dismissing exactly when the touch hits the inputContainerView while panning
    public convenience init(height: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    override public func willMove(toSuperview newSuperview: UIView?) {
        if didAddObserver {
            superview?.removeObserver(self, forKeyPath: #keyPath(frame))
            superview?.removeObserver(self, forKeyPath: #keyPath(center))
        }

        newSuperview?.addObserver(self, forKeyPath: #keyPath(frame), options: [.new], context: nil)
        newSuperview?.addObserver(self, forKeyPath: #keyPath(center), options: [.new], context: nil)

        didAddObserver = true

        super.willMove(toSuperview: newSuperview)
    }

    override public func removeFromSuperview() {
        super.removeFromSuperview()
        resetKeyboardFrame()
    }

    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey: Any]?,
                                      context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(frame) || keyPath == #keyPath(center) {
            self.superViewFrameDidChange()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        superViewFrameDidChange()
    }

    private func superViewFrameDidChange() {
        if let frame = superview?.frame {
            onKeyboardFrameDidChange?(frame)
            delegate?.keyboardFrameDidChange(with: frame)
        }
    }

    private func resetKeyboardFrame() {
        let frame = CGRect(origin: .init(x: 0, y: UIScreen.main.bounds.height), size: .zero)
        onKeyboardFrameDidChange?(frame)
        delegate?.keyboardFrameDidChange(with: frame)
    }

    public func setHeight(_ height: CGFloat) {
        frame = CGRect(x: 0, y: 0, width: 0, height: height)

        if let constraint = constraints.first(where: { $0.firstAttribute == .height }) {
            constraint.constant = height
        }
    }

    // remove all observers when deinitialized
    deinit {
        self.superview?.removeObserver(self, forKeyPath: #keyPath(frame))
        self.superview?.removeObserver(self, forKeyPath: #keyPath(center))
    }
}
