//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

protocol DegenService: AnyObject {

    func categories() -> [DAppCategory]
    func dapps(for category: DAppCategory) -> [DApp]
}

final class DefaultDegenService {

}

extension DefaultDegenService: DegenService {

    func categories() -> [DAppCategory] {
        
        DAppCategory.all()
    }

    func dapps(for category: DAppCategory) -> [DApp] {
        
        switch category {
        case .amm:
            return [
                DApp(name: "Uniswap", network: "Ethereum"),
                DApp(name: "Sushiswap", network: "Ethereum"),
                DApp(name: "Raydium", network: "Solana"),
                DApp(name: "Orca", network: "Solana"),
                DApp(name: "Curve", network: "Ethereum"),
                DApp(name: "1inch", network: "Ethereum"),
            ]
        default:
            return []
        }
    }
}
