// Created by web3d3v on 05/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

extension UIAlertController {

    convenience init(
        _ viewModel: ErrorViewModel,
        handlers: [((UIAlertAction) -> Void)?]
    ) {
        self.init(
            title: viewModel.title,
            message: viewModel.body,
            preferredStyle: .alert
        )
        for (idx, val) in viewModel.actions.enumerated() {
            let handler = handlers[safe: idx]
            addAction(
                .init(title: val, style: .default, handler: handler ?? nil)
            )
        }
    }
}
