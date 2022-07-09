// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Security
import web3lib

protocol OldKeyChainService: AnyObject {

    func addItem(_ item: KeyStoreItem) throws
    func item(for: KeyStoreItem) throws -> Data?
    func removeItem(_ item: KeyStoreItem)
    func allKeyStoreItems() throws -> [Data]

    func generatePassword(_ id: String, sync: Bool) throws
    func addPassword(_ password: String, id: String, sync: Bool) throws
    func password(for id: String) throws -> String?
    func removePassword(id: String)
}

final class DefaultKeyChainService: OldKeyChainService {
    
    func addItem(_ item: KeyStoreItem) throws {
        guard let data = try item.secretStorage?.data() else {
            throw KeyChainError.failedToEncodeSecretStorage
        }
        let sync = item.iCloudSecretStorage
        try addItem(id: item.id, data: data, sync: sync, type: .secretStorage)
    }

    func item(for item: KeyStoreItem) throws -> Data? {
        return try self.item(for: item.id, type: .secretStorage)
    }

    func removeItem(_ item: KeyStoreItem) {
        removeItem(id: item.id, type: .secretStorage)
    }

    func allKeyStoreItems() throws -> [Data] {
        let query = [
            kSecAttrService: ItemType.secretStorage.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            kSecMatchLimit: Constant.maxWalletCount,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard status == errSecSuccess, let items = result as? [NSDictionary] else {
            throw KeyChainError.failedToRetrieveItem
        }

        return items
            .map { $0[kSecValueData] as? Data }
            .compactMap { $0 }
    }
    
    func generatePassword(_ id: String, sync: Bool) throws {
        let password = (try Data.secRandom(16)).hexString()
        try addPassword(password, id: id, sync: sync)
    }
    
    func addPassword(_ password: String, id: String, sync: Bool) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeyChainError.failedToEncodePasswordToData
        }
        try addItem(id: id, data: data, sync: sync, type: .password)
    }
    
    func password(for id: String) throws -> String? {
        guard let data = try item(for: id, type: .password),
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }

    func removePassword(id: String) {
        removeItem(id: id, type: .password)
    }
}


extension DefaultKeyChainService {

    enum KeyChainError: Error {
        case failedToStoreSecretStorage
        case failedToStorePassword
        case failedToEncodeSecretStorage
        case failedToEncodePasswordToData
        case failedToRetrieveItem
    }
}

extension DefaultKeyChainService {

    enum ItemType: String {
        case password = "com.sonsOfCrypto.web3Wallet.password"
        case secretStorage = "com.sonsOfCrypto.web3Wallet.secreteStorage"

        func toServiceType() -> ServiceType {
            switch self {
            case .password:
                return ServiceType.password
            case .secretStorage:
                return ServiceType.secretStorage
            }
        }
    }
}

extension DefaultKeyChainService {

    enum Constant {
        static let maxWalletCount = 100000000
    }
}

extension DefaultKeyChainService {

    func addItem(id: String, data: Data, sync: Bool, type: ItemType) throws {
        try set(id: id, data: data.byteArray(), type: type.toServiceType(), icloud: sync)
    }

    func item(for id: String, type: ItemType) throws -> Data? {
        try get(id: id, type: type.toServiceType()).toDataFull()
    }

    func removeItem(id: String, type: ItemType) {
        try remove(id: id, type: type.toServiceType())
    }
}

// MARK: - web3lib.KeyChainService

extension DefaultKeyChainService: KeyChainService {
    
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
        return "Keychain Status: Unknown. (\(resultCode))"
    }
}

// MARK: - Assembler

final class KeyChainServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { _ -> OldKeyChainService in

            DefaultKeyChainService()
        }
    }
}