// Created by web3d4v on 07/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

extension Currency {
    
    func fiatValue(for amount: BigInt) -> Double {
        guard let decimals = decimals?.uintValue else { return .zero }
        let bigDecBalance = amount.toBigDec(decimals: decimals)
        let bigDecFiatPrice = BigDec.Companion().from(double: fiatPrice)
        let result = bigDecBalance.mul(value: bigDecFiatPrice)
        return result.toDouble()
    }
    
    var fiatPrice: Double {
        let currencyStoreService: CurrencyStoreService = ServiceDirectory.assembler.resolve()
        return currencyStoreService.marketData(currency: self)?.currentPrice?.doubleValue ?? 0
    }
}
