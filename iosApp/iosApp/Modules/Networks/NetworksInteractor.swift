// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol NetworkInteractorLister: AnyObject {
    func handle(_ event: WalletsConnectionServiceEvent)
}

protocol NetworksInteractor: AnyObject {
    var selected: Network? { get set }

    func set(_ network: Network, enabled: Bool)
    func isEnabled(_ network: Network) -> Bool

    func networks() -> [Network]
    func image(_ network: Network) -> Data
    func provider(_ network: Network) -> Provider?

    func addListener(_ listener: NetworkInteractorLister)
    func removeListener(_ listener: NetworkInteractorLister?)
}

final class DefaultNetworksInteractor {

    var selected: Network? {
        get { walletsConnectionService.network }
        set { walletsConnectionService.network = newValue }
    }

    private let walletsConnectionService: WalletsConnectionService
    private let currencyMetadataService: CurrencyMetadataService
    private let currenciesService: CurrenciesService
    private var listeners: [WeakContainer] = []

    init(
        _ walletsConnectionService: WalletsConnectionService,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.walletsConnectionService = walletsConnectionService
        self.currenciesService = currenciesService
        self.currencyMetadataService = currencyMetadataService
    }
}

extension DefaultNetworksInteractor: NetworksInteractor {

    func networks() -> [Network] {
        Network.Companion().supported()
    }

    func image(_ network: Network) -> Data {
        currencyMetadataService.cachedImage(currency: network.nativeCurrency)?
            .toDataFull() ?? UIImage(named: "currency_placeholder")!.pngData()!
    }

    func provider(_ network: Network) -> Provider? {
        walletsConnectionService.provider(network: network)
    }

    func isEnabled(_ network: Network) -> Bool {
        walletsConnectionService.enabledNetworks().contains(network)
    }

    func set(_ network: Network, enabled: Bool) {
        walletsConnectionService.setNetwork(network: network, enabled: enabled)
    }
}

// MARK: - Listeners

extension DefaultNetworksInteractor: WalletsConnectionServiceListener {

    func addListener(_ listener: NetworkInteractorLister) {
        if listeners.isEmpty {
            walletsConnectionService.addListener(listener: self)
        }
        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: NetworkInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            walletsConnectionService.removeListener(listener: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            walletsConnectionService.removeListener(listener: nil)
        }
    }

    private func emit(_ event: WalletsConnectionServiceEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event: WalletsConnectionServiceEvent) {
        if let network = (event as? WalletsConnectionServiceEvent.NetworkSelected)?.network,
           let wallet = walletsConnectionService.wallet,
           currenciesService.currencies(wallet: wallet, network: network).isEmpty {
                currenciesService.generateDefaultCurrenciesIfNeeded(
                    wallet: wallet,
                    network: network
                )
        }

        emit(event)
    }

    private class WeakContainer {
        weak var value: NetworkInteractorLister?

        init(_ value: NetworkInteractorLister) {
            self.value = value
        }
    }
}
