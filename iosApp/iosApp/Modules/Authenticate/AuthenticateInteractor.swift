// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol AuthenticateInteractor: AnyObject {
    func canUnlockWithBio(_ keyStoreItem: KeyStoreItem) -> Bool
    func unlockWithBiometrics(
        _ item: KeyStoreItem,
        title: String,
        handler: @escaping (Result<(String, String), Error>) -> Void
    )
    func isValid(item: KeyStoreItem, password: String, salt: String) -> Bool
}

// MARK: - DefaultAuthenticateInteractor

class DefaultAuthenticateInteractor {

    private var keyStoreService: KeyStoreService

    init(keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultAuthenticateInteractor

extension DefaultAuthenticateInteractor: AuthenticateInteractor {

    func canUnlockWithBio(_ keyStoreItem: KeyStoreItem) -> Bool {
        keyStoreItem.canUnlockWithBio() && keyStoreService.biometricsSupported()
    }

    func unlockWithBiometrics(
        _ item: KeyStoreItem,
        title: String,
        handler: @escaping (Result<(String, String), Error>) -> Void
    ) {
        keyStoreService.biometricsAuthenticate(
            title: title,
            handler: { success, error in
                DispatchQueue.main.async {
                    if success.boolValue {
                        let pass = self.keyStoreService.password(item: item) ?? ""
                        handler(.success((pass, "")))
                    } else {
                        handler(.failure(error ?? GlobalError.unknown))
                    }
                }
            }
        )
    }

    func isValid(item: KeyStoreItem, password: String, salt: String) -> Bool {
        guard let secretStorage = keyStoreService.secretStorage(
            item: item,
            password: password
        ) else {
            return false
        }

        return (try? secretStorage.decrypt(password: password)) != nil
    }
}
