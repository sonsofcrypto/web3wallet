// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

extension AlertWireframeContext {
    static func underConstructionAlert(onOkTapped: ((Int) -> Void)? = nil) -> AlertWireframeContext {
        AlertWireframeContext.Companion().underConstructionAlert(onActionTapped: { idx in onOkTapped?(idx.intValue) }) 
    }
}
