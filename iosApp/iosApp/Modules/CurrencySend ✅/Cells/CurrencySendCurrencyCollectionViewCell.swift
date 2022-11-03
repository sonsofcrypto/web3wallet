// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class CurrencySendCurrencyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var currencyView: CurrencyAmountPickerView!
    
    struct Handler {
        let onCurrencyTapped: (() -> Void)?
        let onAmountChanged: ((BigInt) -> Void)?
    }
        
    override func resignFirstResponder() -> Bool {
        currencyView.resignFirstResponder()
    }
}

extension CurrencySendCurrencyCollectionViewCell {
    
    func update(
        with viewModel: CurrencyAmountPickerViewModel,
        handler: Handler
    ) {
        currencyView.update(
            with: viewModel,
            onCurrencyTapped: handler.onCurrencyTapped,
            onAmountChanged: handler.onAmountChanged
        )
    }
}
