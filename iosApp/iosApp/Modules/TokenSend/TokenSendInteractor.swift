// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol TokenSendInteractor: AnyObject {

    var defaultToken: Web3Token { get }
    func isAddressValid(
        address: String,
        network: Web3Network
    ) -> Bool
    
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String
    
    func tokenIcon(for token: Web3Token) -> Data
    func networkFees(network: Web3Network) -> [Web3NetworkFee]
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String
}

final class DefaultTokenSendInteractor {

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenSendInteractor: TokenSendInteractor {
    
    var defaultToken: Web3Token {
        
        web3Service.myTokens.first ?? web3Service.allTokens.first!
    }

    func isAddressValid(
        address: String,
        network: Web3Network
    ) -> Bool {
        
        web3Service.isValid(address: address, forNetwork: network)
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
    
    func tokenIcon(for token: Web3Token) -> Data {
        
        web3Service.tokenIcon(for: token)
    }
    
    func networkFees(network: Web3Network) -> [Web3NetworkFee] {
        
        [.low, .medium, .high]
    }

    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double {
        
        web3Service.networkFeeInUSD(network: network, fee: fee)
    }
    
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int {
    
        web3Service.networkFeeInSeconds(network: network, fee: fee)
    }

    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String {
        
        web3Service.networkFeeInNetworkToken(network: network, fee: fee)
    }
}
