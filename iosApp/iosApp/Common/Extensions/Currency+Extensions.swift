// Created by web3d4v on 07/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

extension Currency {
    
    var iconName: String { coinGeckoId ?? "currency_placeholder" }
    
    func fiatValue(for amount: BigInt) -> Double {
        let bigDecBalance = amount.toBigDec(decimals: UInt(decimals()))
        let bigDecFiatPrice = BigDec.Companion().from(double: fiatPrice)
        let result = bigDecBalance.mul(value: bigDecFiatPrice)
        return result.toDouble()
    }
    
    var fiatPrice: Double {
        let currencyStoreService: CurrencyStoreService = AppAssembler.resolve()
        return currencyStoreService.marketData(currency: self)?.currentPrice?.doubleValue ?? 0
    }
    
    var decimalsUInt: UInt { UInt(decimals()) }
}

extension Array where Element == Currency {
    func filterBy(searchTerm: String) -> [Currency] {
        filter {
            let searchTermMatching =
                $0.name.capitalized.hasPrefix(searchTerm.capitalized) ||
                $0.symbol.capitalized.hasPrefix(searchTerm.capitalized)
            return searchTerm.isEmpty ? true : searchTermMatching
        }
    }

}
