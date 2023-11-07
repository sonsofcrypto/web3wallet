//
// Created by anon on 22/09/2023.
//

import UIKit

extension String {

    var decimals: String? {
        let split = self.split(separator: ".")
        guard split.count == 2 else { return nil }
        return String(split[1])
    }

    static func currencySymbol(
        with currencyCode: String = "USD"
    ) -> String {
        let formatter = NumberFormatter()
        formatter.currencyCode = "usd"
        formatter.numberStyle = .currency
        formatter.locale = .init(identifier: "en")

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