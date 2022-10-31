// Created by web3d4v on 17/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

extension NSAttributedString {
    
    convenience init(
        _ output: [Formatters.Output],
        font: UIFont = Theme.font.dashboardTVBalance,
        fontSmall: UIFont = Theme.font.caption2,
        foregroundColor color: UIColor = Theme.colour.labelPrimary
    ) {
        let string = output.reduce(into: "") {
            if let output = $1 as? Formatters.OutputNormal { $0 = $0 + output.value }
            if let output = $1 as? Formatters.OutputUp { $0 = $0 + output.value }
            if let output = $1 as? Formatters.OutputDown { $0 = $0 + output.value }
        }
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let atrStr = NSMutableAttributedString(string: string, attributes: attributes)
        var location = 0
        let offset = font.capHeight - fontSmall.capHeight
        output.forEach {
            if let output = $0 as? Formatters.OutputNormal { location += output.value.count }
            if let output = $0 as? Formatters.OutputUp {
                atrStr.addAttributes(
                    [.font: fontSmall, .baselineOffset: offset],
                    range: NSRange(location: location, length: output.value.count)
                )
                location += output.value.count
            }
            if let output = $0 as? Formatters.OutputDown {
                atrStr.addAttributes(
                    [.font: fontSmall, .baselineOffset: -offset],
                    range: NSRange(location: location, length: output.value.count)
                )
                location += output.value.count
            }
        }
        self.init(attributedString: atrStr)
    }
}
