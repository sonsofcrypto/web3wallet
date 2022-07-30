// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

private let serviceKeyValueStore = "serviceKeyValueStore"
private let currenciesKeyValueStore = "currenciesKeyValueStore"

final class IntegrationWeb3Service {
    
    let web3service: Web3Service

    private let defaults: UserDefaults
    private var supported: [Web3Token] = []

    private var listeners: [Web3ServiceWalletListener] = []
    
    private var currenciesService: CurrenciesService? {
        guard let wallet = web3service.wallet else {
            return nil
        }
        let service = DefaultCurrenciesService(
            wallet: wallet,
            store: KeyValueStore(name: currenciesKeyValueStore)
        )
        return service
    }
    
    init(
        web3service: Web3Service,
        defaults: UserDefaults = .standard
    ) {
        self.web3service = web3service
        self.defaults = defaults
        
        // TODO: @Annon implement
        //        internalService.onTokensUpdated {
        //
        //            self.tokensChanged()
        //        }
    }
    
}

extension IntegrationWeb3Service: Web3ServiceLegacy {
    
    var allNetworks: [Web3Network] {
        Network.Companion().supported().map {
            Web3Network.from(
                $0,
                isOn: web3service.enabledNetworks().contains($0)
            )
        }
    }
    
    var allTokens: [Web3Token] {

        guard let currenciesService = currenciesService else {
            return []
        }
        
        if supported.isEmpty {
            let url = Bundle.main.url(forResource: "coin_cache", withExtension: "json")!
            let data = try! Data(contentsOf: url)
            let string = String(data: data, encoding: .utf8)!
            let web3LibNetwork: web3lib.Network = web3service.network ?? Network.Companion().ethereum()
            let network: Web3Network = Web3Network.from(
                web3LibNetwork,
                isOn: web3service.enabledNetworks().contains(web3LibNetwork)
            )
            supported = currenciesService.currencyList(data: string).map {
                Web3Token.from(
                    currency: $0,
                    network: network,
                    inWallet: currenciesService.currencies(network: web3LibNetwork).contains($0)
                )
            }
        }
        return supported

    }

    var myTokens: [Web3Token] {
        guard let currenciesService = currenciesService else {
            return []
        }
        
        let web3LibNetwork: web3lib.Network = web3service.network
            ?? Network.Companion().ethereum()
        
        let network: Web3Network = Web3Network.from(
            web3LibNetwork,
            isOn: web3service.enabledNetworks().contains(web3LibNetwork)
        )

        return currenciesService.currencies(network: network.toNetwork()).map {
            Web3Token.from(
                currency: $0,
                network: network,
                inWallet: true
            )
        }
    }
    
    func storeMyTokens(to tokens: [Web3Token]) {
        guard let currenciesService = currenciesService else {
            return
        }
        
        tokens.filter { !$0.showInWallet }
            .forEach {
                currenciesService.remove(
                    currency: $0.toCurrency(),
                    network: web3service.network!
                )
            }
        
        tokens.filter { $0.showInWallet }
            .forEach {
                currenciesService.add(
                    currency: $0.toCurrency(),
                    network: web3service.network!
                )
            }
        
        tokensChanged()
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        networkIconName(for: network).loadIconData
    }
    
    func networkIconName(for network: Web3Network) -> String {
        "token_eth_icon"
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        tokenIconName(for: token).loadIconData
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
        web3service.setNetwork(network: network.toNetwork(), enabled: active)
    }
    
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double {
        // TODO: return fees
        return 0.0
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
        // TODO: current block
        return "current block"
    }
    
    func setNotificationAsDone(
        notificationId: String
    ) {
        
        if notificationId == "modal.mnemonic.confirmation" {
            
            let walletId = web3service.wallet?.id() ?? ""
            defaults.bool(forKey: "\(notificationId).\(walletId)")
            listeners.forEach { $0.nftsChanged() }
        }
    }
    
    var dashboardNotifications: [Web3Notification] {
        
        var notifications = [Web3Notification]()
        
        // TODO: @Annon implement
        if let walletId = web3service.wallet?.id(),
            defaults.object(forKey: "modal.mnemonic.confirmation.\(walletId)") == nil
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
