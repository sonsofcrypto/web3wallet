// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class NFTSendCTACollectionViewCell: UICollectionViewCell {
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

extension NFTSendCTACollectionViewCell {
    
    func update(with viewModel: NFTSendViewModel.ItemSend, handler: Handler) {
        self.handler = handler
        switch viewModel.buttonState {
        case .ready:
            button.setTitle(Localized("send"), for: .normal)
            button.isEnabled = true
        case .invalidDestination:
            button.setTitle(Localized("nftSend.missing.address"), for: .normal)
            button.isEnabled = false
        default:
            break
        }
        networkFeeView.update(
            with: viewModel.networkFee,
            handler: handler.onNetworkFeesTapped
        )
    }
}

private extension NFTSendCTACollectionViewCell {
    
    @objc func onSendTapped() { handler.onCTATapped()}
}
