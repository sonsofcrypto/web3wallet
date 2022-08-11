// Created by web3d4v on 11/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

extension BigInt {
    
    static var zero: BigInt {
        
        BigInt.Companion().from(int: 0)
    }
    
    static func > (left: BigInt, right: BigInt) -> Bool {
        
        // TODO: Implement propertly
        left.isEqual(right)
    }
    
    static func == (left: BigInt, right: BigInt) -> Bool {
        
        left.isEqual(right)
    }
    
    static func >= (left: BigInt, right: BigInt) -> Bool {
        
        // TODO: Implement propertly
        left.isEqual(right)
    }
        
    static func < (left: BigInt, right: BigInt) -> Bool {
        
        // TODO: Implement propertly
        left.isEqual(right)
    }
    
    static func * (left: BigInt, right: BigInt) -> BigInt {
        
        left.mul(value: right)
    }
    
    static func / (left: BigInt, right: BigInt) -> BigInt {
        
        left.div(value: right)
    }
    
    static func min (left: BigInt, right: BigInt) -> BigInt {
        
        // TODO: Implement
        left.div(value: right)
    }
}

extension BigInt {
    
    enum FormatType {
        
        case short
        case long
        case max
    }
    
    func toString(
        type: FormatType = .max,
        decimals: UInt
    ) -> String {
        
        ""
    }
    
    func toCurrencyString(
        type: FormatType = .max,
        with currencyCode: String = "USD",
        decimals: Int = 2
    ) -> String {
        
        // TODO: Implement
        return ""
    }
}
//
//extension String {
//
//    func formatCurrency(
//        with currencyCode: String = "USD",
//        maximumFractionDigits: Int = 2
//    ) -> String {
//
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencyCode = currencyCode
//        formatter.maximumFractionDigits = maximumFractionDigits
//
//        // formatted(.currency(code: "USD"))
//        var currencySymbol: String? = formatter.string(from: 0)
//        if currencyCode == "USD" {
//            currencySymbol = currencySymbol?.replacingOccurrences(of: "US", with: "")
//        }
//        currencySymbol = currencySymbol?.replacingOccurrences(of: "0.00", with: "")
//
//        let currencyValue =
//
//        guard let currencySymbol = currencySymbol else { return self }
//
//        return currencySymbol + " " + self
//    }
//}

//private extension String {
//
//    func makeCurrencyValue(
//        with fractionDigits: Int = 2
//    ) {
//
//        guard string.count
//    }
//}
