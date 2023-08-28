// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class CurrencySwapSlippageView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var button: Button!
    
    struct Handler {
        let onSlippageTapped: () -> Void
    }
    
    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.apply(style: .footnote)
        nameLabel.text = Localized("currencySwap.cell.slippage")
        button.style = .secondarySmall(leftImage: nil)
        button.addTarget(
            self,
            action: #selector(changeSlippage),
            for: .touchUpInside
        )
    }
}

extension CurrencySwapSlippageView {
    
    func update(with viewModel: CurrencySwapSlippageViewModel, handler: Handler) {
        self.handler = handler
        button.setTitle(viewModel.value, for: .normal)
    }
}

private extension CurrencySwapSlippageView {
    
    @objc func changeSlippage() {
        handler.onSlippageTapped()
    }
}
