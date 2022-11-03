// Created by web3d4v on 07/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class CurrencySendCTACollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var networkFeeView: NetworkFeeView!
    @IBOutlet weak var button: Button!
    
    struct Handler {
        let onNetworkFeesTapped: () -> Void
        let onCTATapped: () -> Void
    }

    private var handler: Handler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.style = .primary
        button.addTarget(self, action: #selector(onSendTapped), for: .touchUpInside)
    }
}

extension CurrencySendCTACollectionViewCell {
    
    func update(
        with viewModel: CurrencySendViewModel.SendViewModel,
        handler: Handler
    ) {
        self.handler = handler
        switch viewModel.buttonState {
        case .ready:
            button.setTitle(Localized("send"), for: .normal)
            button.isEnabled = true
        case .enterFunds:
            button.setTitle(Localized("enterFunds"), for: .normal)
            button.isEnabled = false
        case .insufficientFunds:
            button.setTitle(Localized("insufficientFunds"), for: .normal)
            button.isEnabled = false
        case .invalidDestination:
            button.setTitle(Localized("currencySend.missing.address"), for: .normal)
            button.isEnabled = false
        default: break
        }
        networkFeeView.update(
            with: viewModel.networkFee,
            handler: handler.onNetworkFeesTapped
        )
    }
}

private extension CurrencySendCTACollectionViewCell {
    
    @objc func onSendTapped() { handler.onCTATapped() }
}
