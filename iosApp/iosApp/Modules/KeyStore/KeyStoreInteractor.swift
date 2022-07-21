// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol KeyStoreInteractor: AnyObject {
    
    var selected: KeyStoreItem? {set get}
    var items: [KeyStoreItem] { get }
    func add(item: KeyStoreItem, password: String, secretStorage: SecretStorage)
}

final class DefaultKeyStoreInteractor {

    private var keyStoreService: KeyStoreService

    init(_ keyStoreService: KeyStoreService) {
        
        self.keyStoreService = keyStoreService
    }
}

extension DefaultKeyStoreInteractor: KeyStoreInteractor {
    
    var selected: KeyStoreItem? {
        get { keyStoreService.selected }
        set { keyStoreService.selected = newValue }
    }

    var items: [KeyStoreItem] {
        keyStoreService.items()
    }

    func add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) {
        
        keyStoreService.add(item: item, password: password, secretStorage: secretStorage)
    }
}
