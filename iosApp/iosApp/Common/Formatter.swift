// Created by web3d3v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

class Formatter {
    static let currency = CurrencyFormatter()
    static let fiat = FiatFormatter()
    static let pct = PctFormatter()
    static let date = DateTimeFormatter()
}

// MARK: - Currency

class CurrencyFormatter {

    var placeholder: String = "-"

    let formatter = web3lib.CurrencyFormatter()

    enum Style {
        case short
        case long
        case max
    }

    func string(
        _ amount: BigInt?,
        currency: Currency,
        style: Style = .max
    ) -> String {
        guard let amount = amount else { return placeholder }
        let amountFormatted: String
        switch style {
        case .short:
            amountFormatted =  amount.formatString(type: .short, decimals: currency.decimals?.uintValue ?? 18)
        case .long:
            amountFormatted =  amount.formatString(type: .long, decimals: currency.decimals?.uintValue ?? 18)
        case .max:
            amountFormatted = amount.formatString(type: .max, decimals: currency.decimals?.uintValue ?? 18)
        }
        return amountFormatted + currency.symbol.uppercased()
    }
}

// MARK: - Fiat

class FiatFormatter {

    var placeholder: String = "-"

    let fiat: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        return formatter
    }()

    func string(_ amount: Float?) -> String {
        guard let amount = amount else { return placeholder }
        return fiat.string(from: amount)
    }

    func string(_ amount: Double?) -> String {
        guard let amount = amount else { return placeholder }
        return string(Float(amount))
    }

    func string(_ amount: KotlinDouble?) -> String {
        guard let amount = amount?.floatValue else { return placeholder }
        return string(amount)
    }
}

// MARK: - Percentage

class PctFormatter {

    var placeholder: String = "-"

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        formatter.numberStyle = .percent
        return formatter
    }()

    func string(_ from: Float?, div: Bool = false) -> String {
        guard let from = from else { return placeholder }
        return formatter.string(from: div ? from / 100 : from)
    }

    func string(_ from: Double?, div: Bool = false) -> String {
        guard let from = from else { return placeholder }
        return string(Float(from), div: div)
    }

    func string(_ from: KotlinDouble?, div: Bool = false) -> String {
        guard let from = from?.floatValue else { return placeholder }
        return string(from, div: div)
    }
}

// MARK: - DateFormatter

class DateTimeFormatter {

    var placeholder: String = "-"

    let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()

    func string(_ date: Date?) -> String {
        guard let date = date else { return placeholder }
        return formatter.string(from: date)
    }

    func string(_ timestamp: Double?) -> String {
        guard let timestamp = timestamp else { return placeholder }
        return string(Date(timeIntervalSince1970: timestamp))
    }
}
