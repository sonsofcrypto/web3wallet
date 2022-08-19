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
        
        guard text.isValidRegex(#"(?=.{8,})"#) else {
            
            return Localized("validation.error.pin.min.length")
        }

        guard text.isValidRegex(#"^(\d)(?!\1+$)\d{7}$"#) else {
            
            return Localized("validation.error.pin.weak")
        }
        
        return nil
    }
    
    func makePassValidationError(for text: String) -> String? {
        
        guard text.isValidRegex(#"(?=.{8,})"#) else {
            
            return Localized("validation.error.pass.min.lenght")
        }

        guard text.isValidRegex(#"(?=.*[A-Z])"#) else {
            
            return Localized("validation.error.pass.min.capital")
        }

        guard text.isValidRegex(#"(?=.*[a-z])"#) else {
            
            return Localized("validation.error.pass.min.lowercase")
        }

        guard text.isValidRegex(#"(?=.*\d)"#) else {
            
            return Localized("validation.error.pass.min.digit")
        }

        guard text.isValidRegex(#"(?=.*[ !$%&?._-])"#) else {
            
            return Localized("validation.error.pass.min.special")
        }
                
        return nil
    }
}
