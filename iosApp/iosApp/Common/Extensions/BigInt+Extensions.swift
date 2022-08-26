// Created by web3d4v on 11/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

extension BigInt {
    
    static func fromString(
        _ text: String?,
        decimals: UInt
    ) -> BigInt {
        
        guard let text = text, !text.isEmpty else {
            return .zero
        }
        
        do {
            guard let currentDecimals = text.decimals else {
                let fullDecimals = "".addRemainingDecimals(upTo: decimals)
                return try BigInt.Companion().from(
                    string: text.trimFinalDotIfNeeded + fullDecimals,
                    base: Int32(10)
                )
            }
            
            let numberWithoutDecimals = text.split(separator: ".")[0]
            let fullDecimals = currentDecimals.addRemainingDecimals(upTo: decimals)
            
            return try BigInt.Companion().from(
                string: numberWithoutDecimals + fullDecimals,
                base: Int32(10)
            )
            
        } catch {
            return .zero
        }
    }
    
    static var zero: BigInt {
        
        BigInt.Companion().from(int: 0)
    }
    
    static func < (left: BigInt, right: BigInt) -> Bool {
        
        left.compare(other: right) == -1
    }
    
    static func == (left: BigInt, right: BigInt) -> Bool {
        
        left.compare(other: right) == 0
    }
    
    static func != (left: BigInt, right: BigInt) -> Bool {
        
        left.compare(other: right) != 0
    }
    
    static func > (left: BigInt, right: BigInt) -> Bool {
        
        left.compare(other: right) == 1
    }

    static func >= (left: BigInt, right: BigInt) -> Bool {
        
        left > right || left == right
    }
        
    static func * (left: BigInt, right: BigInt) -> BigInt {
        
        left.mul(value: right)
    }
    
    static func / (left: BigInt, right: BigInt) -> BigInt {
        
        guard right != .zero else { return .zero }
        
        do {
            
            return try left.div(value: right)
        } catch {
            
            return .zero
        }
        
    }
    
    static func min (left: BigInt, right: BigInt) -> BigInt {
        
        left < right ? left : right
    }
}

extension BigInt {
    
    enum FormatType {
        
        case short
        case long(minDecimals: Int)
        case max(trimFinalZeros: Bool)
        
        static var long: Self {
            .long(minDecimals: 4)
        }
        
        static var max: Self {
            .max(trimFinalZeros: true)
        }
    }
    
    func toBigDec(
        decimals: UInt
    ) -> BigDec {
        
        let string = formatString(type: .max(trimFinalZeros: false), decimals: decimals)
        return BigDec.Companion().from(string: string, base: Int32(10))
    }
    
    func formatString(
        type: FormatType = .max,
        decimals: UInt
    ) -> String {
        
        switch type {
        case .short:
            return toDecimalString().add(decimals: decimals).trimDecimals(minDecimals: 4).trimFinalZerosIfDecimal(min: 1)
        case let .long(minDecimals):
            return toDecimalString().add(decimals: decimals).trimDecimals(minDecimals: minDecimals).trimFinalZerosIfDecimal(min: 1)
        case let .max(trimFinalZeros):
            if trimFinalZeros {
                return toDecimalString().add(decimals: decimals).trimFinalZerosIfDecimal(min: 1)
            } else {
                return toDecimalString().add(decimals: decimals)
            }
        }
    }
    
    func formatStringCurrency(
        type: FormatType = .max,
        decimals: UInt = 2,
        currencyCode: String = "USD"
    ) -> String {
        
        switch type {
        case .short:
            return String.currencySymbol(with: currencyCode).trimFinalZerosIfDecimal(min: 2).thowsandFormatted
            + toDecimalString().add(decimals: decimals)
        case .long:
            return String.currencySymbol(with: currencyCode)
            + toDecimalString().add(decimals: decimals).trimFinalZerosIfDecimal(min: 2).thowsandFormatted
        case .max:
            return String.currencySymbol(with: currencyCode)
            + toDecimalString().add(decimals: decimals).trimFinalZerosIfDecimal(min: 2).thowsandFormatted
        }
    }
}

extension String {
    
    func add(decimals: UInt) -> String {
        
        var updatedString = self
        var decimalsString = ""
        
        for _ in 0..<decimals {
            
            let decimal = !updatedString.isEmpty ? updatedString.removeLast() : "0"
            decimalsString = String(decimal) + decimalsString
        }
        
        return (updatedString.isEmpty ? "0" : updatedString) + "." + decimalsString
    }
}

private extension String {
    
    var trimFinalDotIfNeeded: String {
        
        guard hasSuffix(".") else { return self }
        
        return replacingOccurrences(of: ".", with: "")
    }
    
    func trimDecimals(minDecimals: Int) -> String {
        
        guard let decimals = decimals, decimals.count > minDecimals else { return self }
        
        let lastIndex = minDecimals - 1
        var newDecimals = ""
        var deleteModelOn = true
        for i in 0...lastIndex {
            
            let character = decimals[lastIndex-i]

            guard deleteModelOn else {
                
                newDecimals = String(character) + newDecimals
                continue
            }
            
            guard i < minDecimals else { continue }
            
            deleteModelOn = false
            newDecimals = String(character) + newDecimals
        }
        
        let nonDecimalPart = split(separator: ".")[0]
        
        return nonDecimalPart + "." + newDecimals
    }
    
    func trimFinalZerosIfDecimal(
        min minDecimals: Int = 2
    ) -> String {
        
        guard let decimals = decimals else { return self }
        
        let lastIndex = decimals.count - 1
        var newDecimals = ""
        var deleteModelOn = true
        for i in 0...lastIndex {
            
            let character = decimals[lastIndex-i]

            guard deleteModelOn else {
                
                newDecimals = String(character) + newDecimals
                continue
            }
            
            guard character != "0" else { continue }
            
            deleteModelOn = false
            newDecimals = String(character) + newDecimals
        }
        
        let nonDecimalPart = split(separator: ".")[0]
        
        if !newDecimals.isEmpty {
            
            while newDecimals.count < minDecimals {
                newDecimals += "0"
            }
        }
        
        return nonDecimalPart + (newDecimals.isEmpty ? ".\(makeDecimalZeros(with: minDecimals))" : "." + newDecimals)
    }
    
    func makeDecimalZeros(
        with minDecimals: Int
    ) -> String {
        
        var zeros = ""
        for _ in 0..<minDecimals {
            zeros += "0"
        }
        return zeros
    }
    
    func removeTrailingCharacters(n: Int) -> String {
        
        var string = self
        var index = n
        while index > 0 {
            string.removeLast()
            index -= 1
        }
        return string
    }
    
    func addRemainingDecimals(upTo: UInt) -> String {
        
        let missingDecimals = Int(upTo) - count
        
        guard missingDecimals > 0 else { return self }
        
        var toReturn = self
        
        for _ in 0..<missingDecimals {
            toReturn += "0"
        }
        
        return toReturn
    }
    
    var thowsandFormatted: String {
        
        let split = split(separator: ".")
        
        guard split.count == 2 else { return self }
        
        guard split[0].count > 3 else { return self }
        
        let stringToFormat = String(split[0])
        let lastIndex = (stringToFormat.count - 1)
        var result = ""
        var thowsandCount = 0
        for i in 0...lastIndex {
            
            result = stringToFormat[lastIndex-i] + result
            thowsandCount += 1
            
            if thowsandCount == 3 && i != lastIndex {
                thowsandCount = 0
                result = "," + result
            }
        }
        return result + "." + split[1]
    }
}
