// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension Double {
    
    func toString(decimals: Int = 2) -> String {
        
        String(format: "%.\(decimals)f", self)
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
