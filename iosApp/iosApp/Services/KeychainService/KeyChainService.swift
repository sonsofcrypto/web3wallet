// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Security
import web3lib
import LocalAuthentication

// MARK: - web3lib.KeyChainService

final class DefaultKeyChainService { }

extension DefaultKeyChainService: KeyChainService {
    
    func biometricsSupported() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        )
    }

    func biometricsAuthenticate(
        title: String,
        handler: @escaping (KotlinBoolean, KotlinError?) -> Void
    ) {
        let context = LAContext()
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: title,
            reply: { success, error in
                DispatchQueue.main.async {
                    guard let err = error else {
                        handler(KotlinBoolean(bool: success),  nil)
                        return
                    }
                    handler(
                        KotlinBoolean(bool: success),
                        KotlinError(message: err.localizedDescription)
                    )
                }
            }
        )
    }

    func get(id: String, type: ServiceType) throws -> KotlinByteArray {
        let query = [
            kSecAttrAccount: id,
            kSecAttrService: type.serviceString(),
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard status == errSecSuccess, let info = result as? NSDictionary else {
            throw KeyChainServiceErr.GetErr(info: "\(statusCodeString(status))")
        }

        guard let data = (info[kSecValueData] as? Data)?.byteArray() else {
            throw KeyChainServiceErr.GetNoDataErr()
        }

        return data
    }

    func set(id: String, data: KotlinByteArray, type: ServiceType, icloud: Bool) throws {
        let attributes = [
            kSecAttrAccount: id,
            kSecAttrService: type.serviceString(),
            kSecClass: kSecClassGenericPassword,
            kSecValueData: data.toDataFull(),
            kSecAttrSynchronizable: icloud,
            kSecAttrAccessible: icloud
                ? kSecAttrAccessibleAfterFirstUnlock
                : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ] as CFDictionary

        var result: AnyObject?
        let status = Security.SecItemAdd(attributes, &result)

        guard status == errSecSuccess else {
            throw KeyChainServiceErr.SetErr(info: "\(statusCodeString(status))")
        }
    }

    func remove(id: String, type: ServiceType) {
        let query = [
            kSecAttrAccount: id,
            kSecAttrService: type.serviceString(),
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        guard SecItemCopyMatching(query, nil) != errSecItemNotFound  else {
            return
        }

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - KeyChainServiceErr

extension KeyChainServiceErr: Swift.Error { }

// MARK: - OSStatus to string

private func statusCodeString(_ status: OSStatus) -> String {
    // See: https://www.osstatus.com/
    switch status {
    case errSecSuccess:
        return "Keychain Status: No error."
    case errSecUnimplemented:
        return "Keychain Status: Function or operation not implemented."
    case errSecIO:
        return "Keychain Status: I/O error (bummers)"
    case errSecOpWr:
        return "Keychain Status: File already open with with write permission"
    case errSecParam:
        return "Keychain Status: One or more parameters passed to a function where not valid."
    case errSecAllocate:
        return "Keychain Status: Failed to allocate memory."
    case errSecUserCanceled:
        return "Keychain Status: User canceled the operation."
    case errSecBadReq:
        return "Keychain Status: Bad parameter or invalid state for operation."
    case errSecInternalComponent:
        return "Keychain Status: Internal Component"
    case errSecNotAvailable:
        return "Keychain Status: No keychain is available. You may need to restart your computer."
    case errSecDuplicateItem:
        return "Keychain Status: The specified item already exists in the keychain."
    case errSecItemNotFound:
        return "Keychain Status: The specified item could not be found in the keychain."
    case errSecInteractionNotAllowed:
        return "Keychain Status: User interaction is not allowed."
    case errSecDecode:
        return "Keychain Status: Unable to decode the provided data."
    case errSecAuthFailed:
        return "Keychain Status: The user name or passphrase you entered is not correct."
    default:
        return "Keychain Status: Unknown. (\(status))"
    }
}

// MARK: - Assembler

final class KeyChainServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { _ -> KeyChainService in
            DefaultKeyChainService()
        }
    }
}
