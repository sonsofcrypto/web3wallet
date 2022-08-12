// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

struct SwapDataIn {
    
    let type: `Type`
    let tokenFrom: Web3Token
    let tokenTo: Web3Token
    
    enum `Type` {
        case calculateAmountTo(amountFrom: BigInt)
        case calculateAmountFrom(amountTo: BigInt)
        
        var amountFrom: BigInt {
            
            switch self {
            case let .calculateAmountTo(amount):
                return amount
            case .calculateAmountFrom:
                return BigInt.zero
            }
        }
        
        var amountTo: BigInt {
            
            switch self {
            case .calculateAmountTo:
                return BigInt.zero
            case let .calculateAmountFrom(amount):
                return amount
            }
        }
    }
}

struct SwapDataOut {
    
    let amountFrom: BigInt?
    let amountTo: BigInt?
}

protocol TokenSwapInteractor: AnyObject {

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
    
    func defaultTokenFrom() -> Web3Token
    func defaultTokenTo() -> Web3Token
    
    func swapTokenAmount(
        dataIn: SwapDataIn,
        onCompletion: @escaping (SwapDataOut) -> Void
    )
}

final class DefaultTokenSwapInteractor {

    private let web3Service: Web3ServiceLegacy
    
    init(
        web3Service: Web3ServiceLegacy
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenSwapInteractor: TokenSwapInteractor {

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
        
        let total = 5

        switch network.name.lowercased() {
            
        case "ethereum":
            return address.prefix(2 + total) + "..." + address.suffix(total)

        default:
            return address.prefix(total) + "..." + address.suffix(total)
        }
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
    
    func defaultTokenFrom() -> Web3Token {
        
        web3Service.myTokens[safe: 0] ?? web3Service.allTokens[0]
    }
    
    func defaultTokenTo() -> Web3Token {
        
        web3Service.myTokens[safe: 1] ?? web3Service.allTokens[1]
    }

    func swapTokenAmount(
        dataIn: SwapDataIn,
        onCompletion: @escaping (SwapDataOut) -> Void
    ) {
        
        switch dataIn.type {
            
        case .calculateAmountFrom:
            calculateTokenFrom(dataIn: dataIn, onCompletion: onCompletion)
            
        case .calculateAmountTo:
            calculateTokenTo(dataIn: dataIn, onCompletion: onCompletion)
        }
    }

}

private extension DefaultTokenSwapInteractor {
    
    func calculateTokenFrom(
        dataIn: SwapDataIn,
        onCompletion: @escaping (SwapDataOut) -> Void
    ) {
        
        let amountTo = dataIn.type.amountTo
        
        guard amountTo > BigInt.zero else {
            
            onCompletion(
                .init(
                    amountFrom: .zero,
                    amountTo: .zero
                )
            )
            return
        }
        
        let amountFrom = amountTo * dataIn.tokenTo.usdPrice / dataIn.tokenFrom.usdPrice
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
           
            onCompletion(
                .init(
                    amountFrom: amountFrom,
                    amountTo: amountTo
                )
            )
        }
    }
    
    func calculateTokenTo(
        dataIn: SwapDataIn,
        onCompletion: @escaping (SwapDataOut) -> Void
    ) {
        
        let amountFrom = dataIn.type.amountFrom
        
        guard amountFrom > BigInt.zero else {
            
            onCompletion(
                .init(
                    amountFrom: .zero,
                    amountTo: .zero
                )
            )
            return
        }
        
        let amountTo = amountFrom * dataIn.tokenFrom.usdPrice / dataIn.tokenTo.usdPrice
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
           
            onCompletion(
                .init(
                    amountFrom: amountFrom,
                    amountTo: amountTo
                )
            )
        }
    }
}
