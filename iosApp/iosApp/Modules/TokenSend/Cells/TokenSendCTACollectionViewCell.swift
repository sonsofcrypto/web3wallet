// Created by web3d4v on 07/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendCTACollectionViewCell: UICollectionViewCell {
    
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

extension TokenSendCTACollectionViewCell {
    
    func update(
        with viewModel: TokenSendViewModel.Send,
        handler: Handler
    ) {
        
        self.handler = handler
        
        switch viewModel.buttonState {
        case .ready:
            button.setTitle(Localized("send"), for: .normal)
        case .enterFunds:
            button.setTitle(Localized("enterFunds"), for: .normal)
        case .insufficientFunds:
            button.setTitle(Localized("insufficientFunds"), for: .normal)
        case .invalidDestination:
            button.setTitle(Localized("tokenSend.missing.address"), for: .normal)
        }
        
        networkFeeView.update(
            with: viewModel.tokenNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
    }
}

private extension TokenSendCTACollectionViewCell {
    
    @objc func onSendTapped() {
        
        handler.onCTATapped()
    }
}
