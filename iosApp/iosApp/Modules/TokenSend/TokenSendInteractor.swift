// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol TokenSendInteractor: AnyObject {

    var defaultToken: Web3Token { get }
    var walletAddress: String? { get }
    func isAddressValid(
        address: String,
        network: Web3Network
    ) -> Bool
    
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String
    
    func tokenIconName(for token: Web3Token) -> String
    func networkFees(network: Web3Network) -> [Web3NetworkFee]
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> BigInt
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int
    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String
}

final class DefaultTokenSendInteractor {

    private let web3Service: Web3ServiceLegacy
    
    init(
        web3Service: Web3ServiceLegacy
    ) {
        self.web3Service = web3Service
    }
}

extension DefaultTokenSendInteractor: TokenSendInteractor {
    
    var walletAddress: String? {
        
        let service: NetworksService = ServiceDirectory.assembler.resolve()
        
        return try? service.wallet()?.address()
            .toHexStringAddress()
            .hexString
    }
    
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
        
        web3Service.addressFormattedShort(address: address, network: network)
    }
    
    func tokenIconName(for token: Web3Token) -> String {
        
        web3Service.tokenIconName(for: token)
    }
    
    func networkFees(network: Web3Network) -> [Web3NetworkFee] {
        
        [.low, .medium, .high]
    }

    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> BigInt {
        
        web3Service.networkFeeInUSD(network: network, fee: fee)
    }
    
    func networkFeeInSeconds(network: Web3Network, fee: Web3NetworkFee) -> Int {
    
        web3Service.networkFeeInSeconds(network: network, fee: fee)
    }

    func networkFeeInNetworkToken(network: Web3Network, fee: Web3NetworkFee) -> String {
        
        web3Service.networkFeeInNetworkToken(network: network, fee: fee)
    }
}
