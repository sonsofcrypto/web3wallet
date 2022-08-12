// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

private let serviceKeyValueStore = "serviceKeyValueStore"
private let currenciesKeyValueStore = "currenciesKeyValueStore"

final class IntegrationWeb3Service {

    let walletsConnectionService: WalletsConnectionService
    private let currenciesService: CurrenciesService
    private let walletsStateService: WalletsStateService
    private let defaults: UserDefaults

    private var supported: [Web3Token] = []
    private var listeners: [Web3ServiceWalletListener] = []

    init(
        walletsConnectionService: WalletsConnectionService,
        currenciesService: CurrenciesService,
        walletsStateService: WalletsStateService,
        defaults: UserDefaults = .standard
    ) {
        self.walletsConnectionService = walletsConnectionService
        self.currenciesService = currenciesService
        self.walletsStateService = walletsStateService
        self.defaults = defaults
    }
    
}

extension IntegrationWeb3Service: Web3ServiceLegacy {
    
    var allNetworks: [Web3Network] {
        Network.Companion().supported().map {
            Web3Network.from(
                $0,
                isOn: walletsConnectionService.enabledNetworks().contains($0)
            )
        }
    }
    
    var allTokens: [Web3Token] {
        guard let network = walletsConnectionService.network,
              let wallet = walletsConnectionService.wallet(network: network)
        else {
            return []
        }

        let legacyNetwork: Web3Network = Web3Network.from(
            network,
            isOn: walletsConnectionService.enabledNetworks().contains(network)
        )

        if supported.isEmpty {

            for (idx, currency) in currenciesService.currencies.enumerated() {
                
                supported.append(
                    Web3Token.from(
                        currency: currency,
                        network: legacyNetwork,
                        inWallet: currenciesService.currencies(wallet: wallet)
                            .contains(currency),
                        idx: idx
                    )
                )
            }
        }

        return supported
    }

    var myTokens: [Web3Token] {
        guard let network = walletsConnectionService.network,
              let wallet = walletsConnectionService.wallet(network: network) else {
            return []
        }

        var tokens = [Web3Token]()

        for network in walletsConnectionService.enabledNetworks() {
            let web3network: Web3Network = Web3Network.from(
                network,
                isOn: walletsConnectionService.enabledNetworks().contains(network)
            )
            if let wallet = walletsConnectionService.wallet(network: network) {
                let currencies = currenciesService.currencies(wallet: wallet)
                tokens.append(contentsOf:
                    currencies.toWeb3TokenList(network: web3network, inWallet: true)
                )
            }
        }

        print("=== currencies", tokens.count)
        return tokens
    }

    func networkIcon(for network: Web3Network) -> Data {
        networkIconName(for: network).loadIconData
    }
    
    func networkIconName(for network: Web3Network) -> String {
        "token_eth_icon"
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        var image: UIImage?

        if let id = token.coingGeckoId {
            image = UIImage(named: id + "_large")
        }

        image = image ?? UIImage(named: "currency_placeholder")
        return image!.pngData()!
    }
    
    func tokenIconName(for token: Web3Token) -> String {
        guard let coinGeckoId = token.toCurrency().coinGeckoId else {
            return "t.circle.fill"
        }
        return "\(coinGeckoId)_large"
    }
    
    func addWalletListener(_ listener: Web3ServiceWalletListener) {
        
        guard !listeners.contains(where: { $0 === listener}) else { return }
        
        listeners.append(listener)
    }
    
    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
        
        listeners.removeAll { $0 === listener }
    }
    
    func isValid(address: String, forNetwork network: Web3Network) -> Bool {

        address.hasPrefix("0x") && address.count == 42
    }
    
    func addressFormattedShort(address: String, network: Web3Network) -> String {
        
        let total = 8
        
        switch network.name.lowercased() {
            
        case "ethereum":
            return address.prefix(2 + total) + "..." + address.suffix(total)
            
        default:
            return address.prefix(total) + "..." + address.suffix(total)
        }
    }
    
    func update(network: Web3Network, active: Bool) {
        walletsConnectionService.setNetwork(network: network.toNetwork(), enabled: active)
    }
    
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> BigInt {
        // TODO: return fees
        return .zero
    }
    
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int {
        // TODO: return fees
        return 1
    }
    
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String {
        // TODO: return fees
        return "==="
    }
    
    var currentEthBlock: String {
        guard let wallet = walletsConnectionService.wallet else {
            return ""
        }
        return walletsStateService.blockNumber(wallet: wallet)?.toDecimalString() ?? ""
    }
    
    func setNotificationAsDone(
        notificationId: String
    ) {
        
        if notificationId == "modal.mnemonic.confirmation" {
            
            let walletId = walletsConnectionService.wallet?.id() ?? ""
            defaults.set(true, forKey: "\(notificationId).\(walletId)")
            defaults.synchronize()
            listeners.forEach { $0.notificationsChanged() }
        }
    }
    
    var dashboardNotifications: [Web3Notification] {
        
        var notifications = [Web3Notification]()
        
        if let walletId = walletsConnectionService.wallet?.id(),
            !defaults.bool(forKey: "modal.mnemonic.confirmation.\(walletId)")
        {
            
            notifications.append(
                .init(
                    id: "1",
                    image: makeSecurityImageData(letter: "s"),
                    title: "Mnemonic",
                    body: "Confirm your mnemonic",
                    deepLink: "modal.mnemonic.confirmation",
                    canDismiss: false,
                    order: 1
                )
            )
        }
        
        notifications.append(
            .init(
                id: "2",
                image: makeSecurityImageData(letter: "t"),
                title: "App Themes",
                body: "Fancy a new look?",
                deepLink: "settings.themes",
                canDismiss: false,
                order: 2
            )
        )
        
        notifications.append(
            .init(
                id: "3",
                image: makeSecurityImageData(letter: "f"),
                title: "App Features",
                body: "Your opinion matters to us",
                deepLink: "modal.features",
                canDismiss: false,
                order: 2
            )
        )
        
        return notifications
    }
    
    func nftsChanged() {
        
        listeners.forEach { $0.nftsChanged() }
    }
}

private extension IntegrationWeb3Service {
    
    func tokensChanged() {
        
        listeners.forEach { $0.tokensChanged() }
    }
    
    func makeSecurityImageData(
        letter: String
    ) -> Data {
        
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.colour.labelPrimary,
                .clear
            ]
        )
        
        return "\(letter).circle.fill".assetImage!
            .applyingSymbolConfiguration(config)!
            .pngData()!
    }
}
