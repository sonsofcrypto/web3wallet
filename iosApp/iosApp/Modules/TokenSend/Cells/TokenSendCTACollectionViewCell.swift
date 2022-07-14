// Created by web3d4v on 07/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendCTACollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: Button!
    
    @IBOutlet weak var networkTokenIcon: UIImageView!
    @IBOutlet weak var networkEstimateFeeLabel: UILabel!
    @IBOutlet weak var networkFeeButton: Button!
    
    private weak var presenter: TokenSendPresenter!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
                
        button.style = .primary

        networkTokenIcon.image = .init(named: "send-ethereum-token")

        networkEstimateFeeLabel.font = Theme.font.caption2
        networkEstimateFeeLabel.textColor = Theme.colour.labelPrimary
        
        networkFeeButton.style = .secondarySmall(
            leftImage: .init(named: "dashboard-charging-station")
        )
        networkFeeButton.addTarget(self, action: #selector(changeNetworkFee), for: .touchUpInside)
    }
}

extension TokenSendCTACollectionViewCell {
    
    func update(
        with viewModel: TokenSendViewModel.Send,
        presenter: TokenSendPresenter
    ) {
        
        self.presenter = presenter
        
        switch viewModel.buttonState {
        case .ready:
            button.setTitle(Localized("ready"), for: .normal)
        case .insufficientFunds:
            button.setTitle(Localized("insufficientFunds"), for: .normal)
        }
        
        networkEstimateFeeLabel.text = viewModel.estimatedFee
        
        switch viewModel.feeType {
        case .low:
            networkFeeButton.setTitle(Localized("low"), for: .normal)
        case .medium:
            networkFeeButton.setTitle(Localized("medium"), for: .normal)
        case .high:
            networkFeeButton.setTitle(Localized("high"), for: .normal)
        }
    }
}

private extension TokenSendCTACollectionViewCell {
    
    @objc func changeNetworkFee() {
        
        presenter.handle(.feeTapped)
    }
}
