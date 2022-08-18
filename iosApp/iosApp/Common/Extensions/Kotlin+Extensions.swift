// Created by web3d3v on 13/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

extension KotlinError: Error {}

extension Network {

    static func ethereum() -> Network {
        Network.Companion().ethereum()
    }

    static func goerli() -> Network {
        Network.Companion().goerli()
    }

    static func rinkeby() -> Network {
        Network.Companion().rinkeby()
    }

    static func ropsten() -> Network {
        Network.Companion().ropsten()
    }
}