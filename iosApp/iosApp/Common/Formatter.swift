// Created by web3d3v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

class Formatter {
    static let pct = PctFormatter()
    static let date = DateTimeFormatter()
    static let address = NetworkAddressFormatter()
}

// MARK: - Percentage

class PctFormatter {

    var placeholder: String = "-"

    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.locale = .english
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

final class NetworkAddressFormatter {
    
    func string(
        _ address: String,
        digits: Int = 8,
        for network: Network
    ) -> String {
        
        switch network.name.lowercased() {
        case "ethereum":
            return address.prefix(2 + digits) + "..." + address.suffix(digits)
        default:
            return address.prefix(2 + digits) + "..." + address.suffix(digits)
        }
    }
}
