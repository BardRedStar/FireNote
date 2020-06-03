//
//  String+Extensions.swift
//  FireNote
//
//  Created by Denis Kovalev on 29.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Foundation

/// Returns the string, which contains the passed string N times.
func * (left: String, right: Int) -> String {
    var result = ""
    for _ in 0 ..< right {
        result += left
    }
    return result
}

// MARK: - Validation

extension String {
    /// Checks whether the email address valid or not.
    func isValidEmail() -> Bool {
        let expression = "[A-Z0-9a-z.'_%+-]+@[A-Za-z0-9.'-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", expression)
        return predicate.evaluate(with: self)
    }

    /// Checks whether the password valid or not.
    /// Valid password contains at least 1 uppercase letter, 1 lowercase letter, 1 digit, and at least 8 letters at all.
    func isValidPassword() -> Bool {
        if count < 8 { return false }

        // Count digits, lowercase and uppercase letters
        var lowercaseCount = 0
        var uppercaseCount = 0
        var digitsCount = 0
        forEach { character in
            if character.isNumber { digitsCount += 1 }
            if character.isUppercase { uppercaseCount += 1 }
            if character.isLowercase { lowercaseCount += 1 }
        }

        guard lowercaseCount == 0 || uppercaseCount == 0 || digitsCount == 0 else { return false }

        return true
    }
}
