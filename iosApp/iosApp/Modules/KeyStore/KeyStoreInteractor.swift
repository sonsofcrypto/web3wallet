// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol KeyStoreInteractor: AnyObject {
    var selected: KeyStoreItem? { set get}
    var items: [KeyStoreItem] { get }
    func add(item: KeyStoreItem, password: String, secretStorage: SecretStorage)
}

final class DefaultKeyStoreInteractor {
    private var keyStoreService: KeyStoreService
    private var networksService: NetworksService

    init(
        _ keyStoreService: KeyStoreService,
        networksService: NetworksService
    ) {
        self.keyStoreService = keyStoreService
        self.networksService = networksService
    }
}

extension DefaultKeyStoreInteractor: KeyStoreInteractor {
    
    var selected: KeyStoreItem? {
        get { keyStoreService.selected }
        set { setSelected(newValue) }
    }

    var items: [KeyStoreItem] {
        keyStoreService.items()
    }

    func add(item: KeyStoreItem, password: String, secretStorage: SecretStorage) {
        keyStoreService.add(item: item, password: password, secretStorage: secretStorage)
    }
}

private extension DefaultKeyStoreInteractor {

    func setSelected(_ keyStoreItem: KeyStoreItem?) {
        keyStoreService.selected = keyStoreItem
        guard let keyStoreItem = keyStoreItem else { return }
        networksService.keyStoreItem = keyStoreItem
    }
}
