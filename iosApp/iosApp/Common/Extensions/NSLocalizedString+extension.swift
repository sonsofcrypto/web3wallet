// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

func Localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

func Localized(_ key: String, arg: String) -> String {
    
    NSLocalizedString(key, comment: "").replacingOccurrences(of: "%@", with: arg)
}
