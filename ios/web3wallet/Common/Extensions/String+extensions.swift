// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

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

extension String {
    
    func attributtedString(
        with mainFont: UIFont,
        and mainColour: UIColor,
        updating keywords: [String],
        withColour colour: UIColor,
        andFont font: UIFont
    ) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(
            string: self,
            attributes: [
                .font: mainFont,
                .foregroundColor: mainColour
            ]
        )
        keywords.forEach { keyword in
            
            let range = (lowercased() as NSString).range(of: keyword.lowercased())
            attributedString.setAttributes(
                [
                    .foregroundColor: colour,
                    .font: font
                ],
                range: range
            )
        }
        return attributedString
    }
}
