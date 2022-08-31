// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

// MARK: - Extracting number from string

extension String {
    
    var themeImage: String {
        Theme.name + "-" + self
    }
    
    var url: URL? {
        URL(string: self)
    }

    func int() throws  -> Int {
        guard let num = Int(self) else {
            throw ParseError.failedToParseType(typeStr: "Int", fromStr: self)
        }
        return num
    }

    func double() throws  -> Double {
        guard let num = Double(self) else {
            throw ParseError.failedToParseType(typeStr: "Double", fromStr: self)
        }
        return num
    }

    enum ParseError: Error {

        case failedToParseType(typeStr: String, fromStr: String)

        var errorDescription: String? {
            switch self{
            case let .failedToParseType(typeStr, fromStr):
                return "Failed to parse \(typeStr) out of \(fromStr)"
            }
        }
    }
}

// MARK: - sdbmhash constant seed hash

extension String {

    var sdbmhash: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(0) {
            (Int($1) &+ ($0 << 6) &+ ($0 << 16))
                    .addingReportingOverflow(-$0)
                    .partialValue
        }
    }
}

// MARK: - Fuzzy match

extension String {

    func fuzzyMatch(_ needle: String) -> Bool {
        if needle.isEmpty {
            return true
        }
        var remainder = Array(needle)
        for char in self {
            if char == remainder[remainder.startIndex] {
                remainder.removeFirst()
                if remainder.isEmpty { return true }
            }
        }
        return false
    }
}

// MARK - Sane accessors

extension String {

    subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }

    func substringMax(_ length: Int) -> String {
        self.substring(toIndex: count > length ? length : count)
    }
}

extension String {
    
    var loadIconData: Data {
        assetImage!.pngData()!
    }

    var assetImage: UIImage? {
        UIImage.loadImage(named: self)
    }
    
    var qrCodeData: Data? {
        data(using: .isoLatin1, allowLossyConversion: false)
    }
}

extension String {
    
    func appending(decimals: UInt) -> String {
        var decimalsString = ""
        for _ in 0..<decimals {
            decimalsString = "0" + decimalsString
        }
        return self + decimalsString
    }
    
    var nonDecimals: String {
        let split = self.split(separator: ".")
        guard split.count == 2 else { return self }
        return String(split[0])
    }
    
    var decimals: String? {
        let split = self.split(separator: ".")
        guard split.count == 2 else { return nil }
        return String(split[1])
    }
    
    var stringDroppingLast: String {
        guard count > 0 else { return "" }
        var string = self
        _ = string.removeLast()
        return string
    }
    
    static func currencySymbol(
        with currencyCode: String = "USD"
    ) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        formatter.locale = .english

        let symbol = formatter.string(
            from: 0
        ).replacingOccurrences(
            of: "0.00",
            with: ""
        )
        guard currencyCode == "USD" else { return symbol }
        return symbol.replacingOccurrences(of: "US", with: "")
    }
}

extension String {
    
    func date(using dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = .english
        return formatter.date(from: self)
    }
}

extension String {
    
    func isValidRegex(_ regex: String) -> Bool {
        
        range(
            of: regex,
            options: .regularExpression
        ) != nil
    }
}
