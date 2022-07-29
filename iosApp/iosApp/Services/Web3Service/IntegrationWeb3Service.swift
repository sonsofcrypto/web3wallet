// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class IntegrationWeb3Service {
    
    private let internalService: web3lib.Web3Service
    private let defaults: UserDefaults
    
    private var listeners: [Web3ServiceWalletListener] = []
    
    init(
        internalService: web3lib.Web3Service,
        defaults: UserDefaults = .standard
    ) {
        
        self.internalService = internalService
        self.defaults = defaults
        
        // TODO: @Annon implement
        //        internalService.onTokensUpdated {
        //
        //            self.tokensChanged()
        //        }
    }
}

extension IntegrationWeb3Service: Web3Service {
    
    var allNetworks: [Web3Network] {
        Network.Companion().supported().map {
            .init(
                id: $0.id(),
                name: $0.name,
                cost: "",
                hasDns: false,
                url: nil,
                status: .connected,
                connectionType: .pocket,
                explorer: nil,
                selectedByUser: internalService.enabledNetworks().contians($0)
            )
        }
    }
    var allTokens: [Web3Token] {
        fatalError("allTokens has not been implemented")
    }
    var myTokens: [Web3Token] {
        fatalError("myTokens has not been implemented")
    }
    
    func storeMyTokens(to tokens: [Web3Token]) {
        
        // TODO: ANNON when tokens added to wallet
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
        
        "token_\(token.symbol.lowercased())_icon"
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
        
    }
    
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double {
        fatalError("networkFeeInUSD(network:fee:) has not been implemented")
    }
    
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int {
        fatalError("networkFeeInSeconds(network:fee:) has not been implemented")
    }
    
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String {
        fatalError("networkFeeInNetworkToken(network:fee:) has not been implemented")
    }
    
    var currentEthBlock: String {
        fatalError("currentEthBlock has not been implemented")
    }
    
    func setNotificationAsDone(
        notificationId: String
    ) {
        
        if notificationId == "modal.mnemonic.confirmation" {
            
            let walletId = internalService.wallet.id()
            defaults.bool(forKey: "\(notificationId).\(walletId)")
            listeners.forEach { $0.nftsChanged() }
        }
    }
    
    var dashboardNotifications: [Web3Notification] {
        
        var notifications = [Web3Notification]()
        
        // TODO: @Annon implement
        if
            let walletId = internalService.wallet.id(),
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
