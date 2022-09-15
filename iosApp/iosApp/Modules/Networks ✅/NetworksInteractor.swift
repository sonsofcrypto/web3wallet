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
    func removeListener(_ listener: NetworkInteractorLister)
}

final class DefaultNetworksInteractor {

    private let networksService: NetworksService
    private var listeners: [WeakContainer] = []

    init(_ networksService: NetworksService) {
        self.networksService = networksService
    }
    
    deinit {
        print("[DEBUG][Interactor] deinit \(String(describing: self))")
    }
}

extension DefaultNetworksInteractor: NetworksInteractor {
    
    var selected: Network? {
        get { networksService.network }
        set { networksService.network = newValue }
    }
    
    func set(_ network: Network, enabled: Bool) {
        
        // TODO: @Annon to remove this when the app does not crash if no networks selected
        // at launch
        guard !isDisablingLastNetwork(network: network, enabled: enabled) else { return }
        
        networksService.setNetwork(network: network, enabled: enabled)
        let enabledNetworks = networksService.enabledNetworks()
        if
            let selectedNetwork = networksService.network,
            !enabledNetworks.contains(network: selectedNetwork)
        {
            // Switch selected network if we disabled it and there are other networks enabled
            selected = enabledNetworks.first
        } else if selected == nil {
            // if no selected network, select the first one from enabledNetworks, this will
            // happen when enabling back the first network after unselecting them all.
            selected = enabledNetworks.first
        }
    }
    
    func isEnabled(_ network: Network) -> Bool {
        networksService.enabledNetworks().contains(network)
    }

    func networks() -> [Network] {
        NetworksServiceCompanion().supportedNetworks()
    }

    func imageName(_ network: Network) -> String {
        network.nativeCurrency.coinGeckoId ?? "currency_placeholder"
    }

    func provider(_ network: Network) -> Provider? {
        networksService.provider(network: network)
    }
    
    func addListener(_ listener: NetworkInteractorLister) {
        listeners = [WeakContainer(listener)]
        networksService.add(listener__: self)
    }

    func removeListener(_ listener: NetworkInteractorLister) {
        listeners = []
        networksService.remove(listener__: self)
    }
}

private extension DefaultNetworksInteractor {
    
    func isDisablingLastNetwork(network: Network, enabled: Bool) -> Bool {
        guard !enabled else { return false }
        let enabledNetworks = networksService.enabledNetworks()
        guard enabledNetworks.count == 1 else { return false }
        guard network.chainId == enabledNetworks[0].chainId else { return false }
        return true
    }
}

private extension Array where Element == Network {
    
    func contains(network: Network) -> Bool {
        reduce(into: false) {
            $0 = $0 || ($1.chainId == network.chainId)
        }
    }
}

// MARK: - Listeners

extension DefaultNetworksInteractor: NetworksListener {

    func handle(event_: NetworksEvent) {
        emit(event_)
    }
}

private extension DefaultNetworksInteractor {
    
    func emit(_ event: NetworksEvent) {
        listeners.forEach { $0.value?.handle(event) }
    }

    class WeakContainer {
        weak var value: NetworkInteractorLister?

        init(_ value: NetworkInteractorLister) {
            self.value = value
        }
    }
}
