//
// Created by anon on 25/09/2023.
//

import Foundation
import web3walletcore

protocol SettingsService {

}

class DefaultSettingsService: SettingsService {

    private let store: KeyValueStore

    init(store: KeyValueStore) {
        self.store = store
    }
}

final class SettingsServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> SettingsService in
            DefaultSettingsService(
                store: KeyValueStore(name: "SettingsService")
            )
        }
    }
}
