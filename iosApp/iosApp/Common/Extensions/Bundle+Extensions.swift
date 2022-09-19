// Created by web3d3v on 19/09/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension Bundle {

    func version() -> String {
        infoDictionary?["CFBundleShortVersionString"] as! String
    }

    func build() -> String {
        infoDictionary?["CFBundleVersion"] as! String
    }
}