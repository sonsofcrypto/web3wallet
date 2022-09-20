// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class NFTSendCTACollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var networkFeeView: TokenNetworkFeeView!
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

extension NFTSendCTACollectionViewCell {
    
    func update(
        with viewModel: NFTSendViewModel.Send,
        handler: Handler
    ) {
        self.handler = handler
        switch viewModel.buttonState {
        case .ready:
            button.setTitle(Localized("send"), for: .normal)
            button.isEnabled = true
        case .invalidDestination:
            button.setTitle(Localized("nftSend.missing.address"), for: .normal)
            button.isEnabled = false
        }
        networkFeeView.update(
            with: viewModel.tokenNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
    }
}

private extension NFTSendCTACollectionViewCell {
    
    @objc func onSendTapped() { handler.onCTATapped()}
}
