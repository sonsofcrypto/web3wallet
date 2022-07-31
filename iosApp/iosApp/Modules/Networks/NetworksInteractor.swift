// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol NetworkInteractorLister: AnyObject {
    func handle(_ event: Web3ServiceEvent)
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
        get { web3service.network }
        set { web3service.network = newValue }
    }

    private let web3service: Web3Service
    private let currencyMetadataService: CurrencyMetadataService
    private let currenciesService: CurrenciesService
    private var listeners: [WeakContainer] = []

    init(
        _ web3service: Web3Service,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.web3service = web3service
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
        web3service.provider(network: network)
    }

    func isEnabled(_ network: Network) -> Bool {
        web3service.enabledNetworks().contains(network)
    }

    func set(_ network: Network, enabled: Bool) {
        web3service.setNetwork(network: network, enabled: enabled)
    }
}

// MARK: - Listeners

extension DefaultNetworksInteractor: Web3ServiceListener {

    func addListener(_ listener: NetworkInteractorLister) {
        if listeners.isEmpty {
            web3service.addListener(listener: self)
        }
        listeners = listeners + [WeakContainer(listener)]
    }

    func removeListener(_ listener: NetworkInteractorLister?) {
        guard let listener = listener else {
            listeners = []
            web3service.removeListener(listener: nil)
            return
        }

        listeners = listeners.filter { $0.value !== listener }

        if listeners.isEmpty {
            web3service.removeListener(listener: nil)
        }
    }

    private func emit(_ event: Web3ServiceEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    func handle(event: Web3ServiceEvent) {
        if let network = (event as? Web3ServiceEvent.NetworkSelected)?.network,
           let wallet = web3service.wallet,
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
