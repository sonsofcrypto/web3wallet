// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DefaultWeb3Service {
    
    let web3ServiceLocalStorage: Web3ServiceLocalStorage
    
    private var listeners: [Web3ServiceWalletListener] = []
    
    init(
        web3ServiceLocalStorage: Web3ServiceLocalStorage
    ) {
        
        self.web3ServiceLocalStorage = web3ServiceLocalStorage
    }
}

extension DefaultWeb3Service: Web3Service {
    
    var allNetworks: [Web3Network] {
        
        var networks = web3ServiceLocalStorage.readAllTokens().networks
        networks.append(
            
            .init(
                id: "10",
                name: "Polygon",
                cost: "5k LAMPORTS - $0.01",
                hasDns: false,
                url: nil,
                status: .comingSoon,
                connectionType: nil,
                explorer: nil,
                selectedByUser: false
            )
        )
        return networks
    }
    
    var allTokens: [Web3Token] {
        
        web3ServiceLocalStorage.readAllTokens().sortByNetworkAndName.filter {
            $0.network.selectedByUser
        }
    }
    
    var myTokens: [Web3Token] {
        
        web3ServiceLocalStorage.readMyTokens().sortByNetworkBalanceAndName.filter {
            $0.network.selectedByUser
        }
    }
    
    func storeMyTokens(to tokens: [Web3Token]) {
        
        web3ServiceLocalStorage.storeMyTokens(with: tokens)
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        
        switch network.name {
            
        case "Bitcoin":
            return "token_btc_icon".loadIconData
            
        case "Ethereum":
            return "token_eth_icon".loadIconData
            
        case "Solana":
            return "token_sol_icon".loadIconData
            
        default:
            
            return "default_token".loadIconData
        }
    }

    func tokenIcon(for token: Web3Token) -> Data {
        
        "token_\(token.symbol.lowercased())_icon".loadIconData
    }
    
    func addWalletListener(_ listener: Web3ServiceWalletListener) {
        
        web3ServiceLocalStorage.addWalletListener(listener)
        
        guard !listeners.contains(where: { $0 === listener}) else { return }
        
        listeners.append(listener)
    }
    
    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
        
        web3ServiceLocalStorage.removeWalletListener(listener)
        
        listeners.removeAll { $0 === listener }
    }
    
    func isValid(address: String, forNetwork network: Web3Network) -> Bool {
        
        switch network.name.lowercased() {
            
        case "ethereum":
            return address.hasPrefix("0x") && address.count == 42
            
        case "solana":
            return true
            
        default:
            return false
        }
    }
    
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String {
        
        let total = 8

        switch network.name.lowercased() {
            
        case "ethereum":
            return address.prefix(2 + total) + "..." + address.suffix(total)

        default:
            return address.prefix(total) + "..." + address.suffix(total)
        }
    }
    
    func update(network: Web3Network, active: Bool) {
        
        web3ServiceLocalStorage.update(network: network, active: active)
    }
    
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double {
        
        switch fee {
        case .low:
            return 0.25
        case .medium:
            return 0.75
        case .high:
            return 1.45
        }
    }
    
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int {
        
        switch fee {
        case .low:
            return 65
        case .medium:
            return 30
        case .high:
            return 6
        }
    }
    
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String {

        switch fee {
        case .low:
            return "14 gwei"
        case .medium:
            return "17 gwei"
        case .high:
            return "18 gwei"
        }
    }
    
    
    var currentEthBlock: String {
        
        return "15223502"
    }

    var dashboardNotifications: [Web3Notification] {
        
        [
            .init(
                id: "1",
                image: makeSecurityImageData(),
                title: "Mnemonic",
                body: "Confirm your mnemonic",
                deepLink: "modal.mnemonic.confirmation",
                canDismiss: false,
                order: 1
            ),
            .init(
                id: "2",
                image: makeSecurityImageData(),
                title: "App Themes",
                body: "Fancy a new look?",
                deepLink: "settings.themes",
                canDismiss: false,
                order: 2
            ),
            .init(
                id: "3",
                image: makeSecurityImageData(),
                title: "Share Us",
                body: "Share on twitter",
                deepLink: "share.twitter",
                canDismiss: false,
                order: 3
            )
        ]
    }
    
    func nftsChanged() {
        
        listeners.forEach { $0.nftsChanged() }
    }
}

private extension DefaultWeb3Service {
    
    func makeSecurityImageData() -> Data {
        
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.colour.labelPrimary,
                .clear
            ]
        )

        return "s.circle.fill".assetImage!
            .applyingSymbolConfiguration(config)!
            .pngData()!
    }
}
