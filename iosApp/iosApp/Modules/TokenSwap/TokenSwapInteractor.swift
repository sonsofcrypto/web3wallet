// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct SwapDataIn {
    
    let type: `Type`
    let tokenFrom: Web3Token
    let tokenTo: Web3Token
    
    enum `Type` {
        case calculateAmountTo(amountFrom: Double)
        case calculateAmountFrom(amountTo: Double)
        
        var amountFrom: Double {
            
            switch self {
            case let .calculateAmountTo(amount):
                return amount
            case .calculateAmountFrom:
                return 0
            }
        }
        
        var amountTo: Double {
            
            switch self {
            case .calculateAmountTo:
                return 0
            case let .calculateAmountFrom(amount):
                return amount
            }
        }
    }
}

struct SwapDataOut {
    
    let amountFrom: Double?
    let amountTo: Double?
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
    
    func tokenIcon(for token: Web3Token) -> Data
    func networkFees(network: Web3Network) -> [Web3NetworkFee]
    func networkFeeInUSD(network: Web3Network, fee: Web3NetworkFee) -> Double
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

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
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
    
    func defaultTokenFrom() -> Web3Token {
        
        web3Service.allTokens[0]
    }
    
    func defaultTokenTo() -> Web3Token {
        
        web3Service.allTokens[1]
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
        
        guard amountTo > 0 else {
            
            onCompletion(
                .init(
                    amountFrom: 0,
                    amountTo: 0
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
        
        guard amountFrom > 0 else {
            
            onCompletion(
                .init(
                    amountFrom: 0,
                    amountTo: 0
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
