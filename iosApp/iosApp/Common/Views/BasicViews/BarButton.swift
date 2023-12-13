// Created by web3d3v on 13/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class BarButton: UIBarButtonItem {
    typealias Handler = (_ idx: Int) -> Void

    private var handler: Handler? = nil

    convenience init(
        tag: Int,
        title: String? = nil,
        style: UIBarButtonItem.Style = .plain,
        handler: Handler? = nil
    ) {
        self.init(
            title: title,
            style: style,
            target: nil,
            action: #selector(buttonAction)
        )
        self.target = self
        self.handler = handler
    }

    @objc func buttonAction(sender: UIBarButtonItem) {
        handler?(tag)
    }
}
