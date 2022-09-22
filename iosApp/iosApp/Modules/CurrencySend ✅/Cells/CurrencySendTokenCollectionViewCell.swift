// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

final class CurrencySendTokenCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tokenView: TokenEnterAmountView!
    
    struct Handler {
        let onTokenTapped: (() -> Void)?
        let onTokenChanged: ((BigInt) -> Void)?
    }
        
    override func resignFirstResponder() -> Bool {
        tokenView.resignFirstResponder()
    }
}

extension CurrencySendTokenCollectionViewCell {
    
    func update(
        with viewModel: TokenEnterAmountViewModel,
        handler: Handler
    ) {
        tokenView.update(
            with: viewModel,
            onTokenTapped: handler.onTokenTapped,
            onTokenChanged: handler.onTokenChanged
        )
    }
}
