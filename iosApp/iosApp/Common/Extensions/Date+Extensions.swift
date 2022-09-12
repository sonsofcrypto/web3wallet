// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension Date {
    
    func formatDate(
        using dateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        timeZone: TimeZone? = TimeZone(abbreviation: "UTC")
    ) -> String {
        
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
}
