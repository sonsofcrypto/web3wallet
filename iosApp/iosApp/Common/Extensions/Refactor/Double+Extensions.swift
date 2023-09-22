// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

extension Double {
        
    var bigDec: BigDec {
        BigDec.Companion().from(double: self)
    }
    
    func toString(decimals: Int = 2) -> String {
        String(format: "%.\(decimals)f", self)
    }
    
    func bigDec(decimals: Int = 2) -> BigDec {
        BigDec.Companion().from(string: String(format: "%.\(decimals)f", self), base: 10.int32)
    }
    
    func format(
        maximumFractionDigits: Int = 2
    ) -> String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = maximumFractionDigits
        
        return formatter.string(from: Double(self) as NSNumber)
    }
    
    func formatCurrency(
        with currencyCode: String = "USD",
        maximumFractionDigits: Int = 2
    ) -> String? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = maximumFractionDigits
        
        // formatted(.currency(code: "USD"))
        var formattedCurrency: String? = formatter.string(from: Float(self))
        if currencyCode == "USD" {
            formattedCurrency = formattedCurrency?.replacingOccurrences(of: "US", with: "")
        }
        return formattedCurrency
    }
}
