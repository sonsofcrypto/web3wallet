// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol NetworkInteractorLister: AnyObject {
    func handle(_ event: NetworksEvent)
}

protocol NetworksInteractor: AnyObject {
    var selected: Network? { get set }

    func set(_ network: Network, enabled: Bool)
    func isEnabled(_ network: Network) -> Bool

    func networks() -> [Network]
    func imageName(_ network: Network) -> String
    func provider(_ network: Network) -> Provider?

    func addListener(_ listener: NetworkInteractorLister)
    func removeListener(_ listener: NetworkInteractorLister?)
}

final class DefaultNetworksInteractor {

    var selected: Network? {
        get { networksService.network }
        set { networksService.network = newValue }
    }

    private let networksService: NetworksService
    private var listeners: [WeakContainer] = []

    init(_ networksService: NetworksService) {
        self.networksService = networksService
    }
}

extension DefaultNetworksInteractor: NetworksInteractor {

    func networks() -> [Network] {
        NetworksServiceCompanion().supportedNetworks()
    }

    func imageName(_ network: Network) -> String {
        network.nativeCurrency.coinGeckoId ?? "currency_placeholder"
    }

    func provider(_ network: Network) -> Provider? {
        networksService.provider(network: network)
    }

    func isEnabled(_ network: Network) -> Bool {
        networksService.enabledNetworks().contains(network)
    }

    func set(_ network: Network, enabled: Bool) {
        networksService.setNetwork(network: network, enabled: enabled)
    }
}

// MARK: - Listeners

extension DefaultNetworksInteractor: NetworksListener {

    func addListener(_ listener: NetworkInteractorLister) {
        if listeners.isEmpty {
            networksService.add(listener__: self)
        }
        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: NetworkInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            networksService.remove(listener__: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            networksService.remove(listener__: nil)
        }
    }

    private func emit(_ event: NetworksEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event_: NetworksEvent) {
        emit(event_)
    }

    private class WeakContainer {
        weak var value: NetworkInteractorLister?

        init(_ value: NetworkInteractorLister) {
            self.value = value
        }
    }
}
