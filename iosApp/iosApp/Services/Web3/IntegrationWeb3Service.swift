// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

private let serviceKeyValueStore = "serviceKeyValueStore"
private let currenciesKeyValueStore = "currenciesKeyValueStore"

final class IntegrationWeb3Service {

    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let defaults: UserDefaults

    private var supported: [Web3Token] = []
    private var listeners: [Web3ServiceWalletListener] = []

    init(
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        defaults: UserDefaults = .standard
    ) {
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.defaults = defaults
    }
    
}

extension IntegrationWeb3Service: Web3ServiceLegacy {
    
    var allNetworks: [Web3Network] {
        NetworksServiceCompanion().supportedNetworks().map {
            Web3Network.from(
                $0,
                isOn: networksService.enabledNetworks().contains($0)
            )
        }
    }
    
    var allTokens: [Web3Token] {
        guard let network = networksService.network else { return [] }

        let legacyNetwork: Web3Network = Web3Network.from(
            network,
            isOn: networksService.enabledNetworks().contains(network)
        )

        if supported.isEmpty {

            var walletCurrenciesIds = [String: Currency]()

            walletService.currencies(network: network).forEach {
                walletCurrenciesIds[$0.id()] = $0
            }

            let currencies = currencyStoreService.currencies(
                network: network,
                limit: 0
            )

            for (idx, currency) in currencies.enumerated() {
                supported.append(
                    Web3Token.from(
                        currency: currency,
                        network: legacyNetwork,
                        inWallet: walletCurrenciesIds[currency.id()] != nil,
                        idx: idx
                    )
                )
            }
        }

        return supported
    }

    var myTokens: [Web3Token] {
        var tokens = [Web3Token]()

        for network in networksService.enabledNetworks() {
            let web3network: Web3Network = Web3Network.from(
                network,
                isOn: networksService.enabledNetworks().contains(network)
            )

            let currencies = walletService.currencies(network: network)
            tokens.append(contentsOf:
                currencies.toWeb3TokenList(network: web3network, inWallet: true)
            )
        }

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
            image = UIImage(named: id)
        }

        image = image ?? UIImage(named: "currency_placeholder")
        return image!.pngData()!
    }
    
    func tokenIconName(for token: Web3Token) -> String {
        guard let coinGeckoId = token.toCurrency().coinGeckoId else {
            return "t.circle.fill"
        }
        return coinGeckoId
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
        networksService.setNetwork(network: network.toNetwork(), enabled: active)
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
        return "🤷🏻‍♂️"
    }
    
    var currentEthBlock: String {
        guard let network = networksService.network else { return "" }
        return walletService.blockNumber(network: network).toDecimalString()
    }
    
    func setNotificationAsDone(
        notificationId: String
    ) {
        
        if notificationId == "modal.mnemonic.confirmation" {
            
            let walletId = networksService.wallet()?.id() ?? ""
            defaults.set(true, forKey: "\(notificationId).\(walletId)")
            defaults.synchronize()
            listeners.forEach { $0.notificationsChanged() }
        }
    }
    
    var dashboardNotifications: [Web3Notification] {
        
        var notifications = [Web3Notification]()
        
        if let walletId = networksService.wallet()?.id(),
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
