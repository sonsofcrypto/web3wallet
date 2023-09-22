// Created by web3d4v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct PasswordValidatorHelper {
    
    enum `Type` {
        
        case pin
        case pass
    }
    
    func validate(_ text: String, type: `Type`) -> String? {
        
        switch type {
        case .pin:
            return makePinValidationError(for: text)
        case .pass:
            return makePassValidationError(for: text)
        }
    }
}

private extension PasswordValidatorHelper {
    
    func makePinValidationError(for text: String) -> String? {
        guard isValidRegex(text: text, regex: #"(?=.{6,})"#) else {
            return Localized("validation.error.pin.min.length")
        }

        guard text[0] != text[1] else {
            return Localized("validation.error.pin.weak")
        }
        
        return nil
    }

    func makePassValidationError(for text: String) -> String? {
        guard isValidRegex(text: text, regex: #"(?=.{8,})"#) else {
            return Localized("validation.error.pass.min.lenght")
        }

        guard isValidRegex(text: text, regex: #"(?=.*[A-Z])"#) else {
            return Localized("validation.error.pass.min.capital")
        }

        guard isValidRegex(text: text, regex: #"(?=.*[a-z])"#) else {
            return Localized("validation.error.pass.min.lowercase")
        }

        guard isValidRegex(text: text, regex: #"(?=.*\d)"#) else {
            return Localized("validation.error.pass.min.digit")
        }
                
        return nil
    }

    private func isValidRegex(text: String?, regex: String) -> Bool {
        guard let text else { return false }
        return text.range(of: regex, options: .regularExpression) != nil
    }
}
