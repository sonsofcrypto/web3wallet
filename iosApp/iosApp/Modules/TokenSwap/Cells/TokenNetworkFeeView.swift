// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct TokenNetworkFeeViewModel {
    
    let estimatedFee: String
    let feeType: FeeType
    
    enum FeeType {
        
        case low
        case medium
        case high
    }
}

final class TokenNetworkFeeView: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var networkTokenIcon: UIImageView!
    @IBOutlet weak var networkEstimateFeeLabel: UILabel!
    @IBOutlet weak var networkFeeButton: Button!
    
    private var handler: (() -> Void)!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        nameLabel.apply(style: .footnote)
        nameLabel.text = Localized("tokenSwap.cell.estimatedFee")
        networkTokenIcon.image = .init(named: "send-ethereum-token")
        networkEstimateFeeLabel.font = Theme.font.footnote
        networkEstimateFeeLabel.textColor = Theme.colour.labelPrimary
        networkFeeButton.style = .secondarySmall(
            leftImage: .init(named: "dashboard-charging-station")
        )
        networkFeeButton.addTarget(self, action: #selector(changeNetworkFee), for: .touchUpInside)
    }
}

extension TokenNetworkFeeView {
    
    func update(
        with viewModel: TokenNetworkFeeViewModel,
        handler: @escaping () -> Void
    ) {
        
        self.handler = handler

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

private extension TokenNetworkFeeView {
    
    @objc func changeNetworkFee() {
        
        handler()
    }
}
