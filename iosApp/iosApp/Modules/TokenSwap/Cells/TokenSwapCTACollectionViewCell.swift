// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSwapCTACollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tokenSwapProviderView: TokenSwapProviderView!
    @IBOutlet weak var networkFeeView: TokenNetworkFeeView!
    @IBOutlet weak var button: Button!
    
    private var handler: Handler!
    
    struct Handler {

        let onNetworkFeesTapped: () -> Void
        let onCTATapped: () -> Void
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
                
        button.style = .primary
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
}

extension TokenSwapCTACollectionViewCell {
    
    func update(
        with viewModel: TokenSwapViewModel.Send,
        handler: Handler
    ) {
        
        self.handler = handler
        
        switch viewModel.buttonState {
        case .ready:
            button.setTitle(Localized("ready"), for: .normal)
        case .insufficientFunds:
            button.setTitle(Localized("insufficientFunds"), for: .normal)
        }
        
        tokenSwapProviderView.update(
            with: viewModel.tokenSwapProviderViewModel
        )
        
        networkFeeView.update(
            with: viewModel.tokenNetworkFeeViewModel,
            handler: handler.onNetworkFeesTapped
        )
    }
}

private extension TokenSwapCTACollectionViewCell {
        
    @objc func buttonTapped() {
        
        handler.onCTATapped()
    }
}
