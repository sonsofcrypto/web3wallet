// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class CurrencySendTokenCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var currencyView: CurrencyEnterAmountView!
    
    struct Handler {
        let onTokenTapped: (() -> Void)?
        let onTokenChanged: ((BigInt) -> Void)?
    }
        
    override func resignFirstResponder() -> Bool {
        currencyView.resignFirstResponder()
    }
}

extension CurrencySendTokenCollectionViewCell {
    
    func update(
        with viewModel: CurrencyEnterAmountViewModel,
        handler: Handler
    ) {
        currencyView.update(
            with: viewModel,
            onTokenTapped: handler.onTokenTapped,
            onTokenChanged: handler.onTokenChanged
        )
    }
}
