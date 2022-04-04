// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

//
// Created by p4rtiz4n on 21/12/2020.
//

import Foundation

// MARK: - Extracting number from string

extension String {

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

// MARK: - suffix number

extension Int {

    var abbreviated: String {
        let abbrev = ["K", " mil", " bil", "T", "P", "E"]
        return abbrev.enumerated()
            .reversed()
            .reduce(nil as String?) { accum, tuple in
                let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
                let truncRemainder = factor.truncatingRemainder(dividingBy: 1)
                let format = truncRemainder == 0 ? "%.0f%@" : "%.1f%@"

                if let accum = accum {
                    return accum
                }

                if factor > 1 {
                    return String(format: format, factor, String(tuple.1))
                }

                return nil
            } ?? String(self)
    }
}
