// Created by web3d3v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

class Formatter {
    static let date = DateTimeFormatter()
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
