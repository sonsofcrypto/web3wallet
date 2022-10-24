// Created by web3d4v on 07/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class CurrencySendCTACollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var networkFeeView: NetworkFeePickerView!
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
        with viewModel: CurrencySendViewModel.Send,
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
        }
        networkFeeView.update(
            with: viewModel.tokenNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
    }
}

private extension CurrencySendCTACollectionViewCell {
    
    @objc func onSendTapped() { handler.onCTATapped() }
}
