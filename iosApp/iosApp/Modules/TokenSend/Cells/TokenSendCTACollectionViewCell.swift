// Created by web3d4v on 07/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSendCTACollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var networkTokenIcon: UIImageView!
    @IBOutlet weak var networkEstimateFeeLabel: UILabel!
    @IBOutlet weak var networkFeeButton: UIButton!
    
    private weak var presenter: TokenSendPresenter!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        (button as? Button)?.style = .primary
        networkTokenIcon.image = .init(named: "send-ethereum-token")
        
        networkEstimateFeeLabel.font = Theme.font.body
        networkEstimateFeeLabel.textColor = Theme.colour.labelPrimary
        
        networkFeeButton.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        networkFeeButton.layer.borderWidth = 0.5
        networkFeeButton.layer.borderColor = Theme.colour.labelPrimary.cgColor
        networkFeeButton.tintColor = Theme.colour.labelPrimary
        
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
            button.setTitle(Localized("tokenSend.cell.send.ready"), for: .normal)
        case .insufficientFunds:
            button.setTitle(Localized("tokenSend.cell.send.insufficientFunds"), for: .normal)
        }
        
        networkEstimateFeeLabel.text = viewModel.estimatedFee
        
        switch viewModel.feeType {
        case .low:
            updateButton(with: Localized("tokenSend.cell.send.fee.low"))
            //networkFeeButton.setTitle(Localized("tokenSend.cell.send.fee.low"), for: .normal)
        case .medium:
            networkFeeButton.setTitle(Localized("tokenSend.cell.send.fee.medium"), for: .normal)
        case .high:
            networkFeeButton.setTitle(Localized("tokenSend.cell.send.fee.high"), for: .normal)
        }
    }
}

private extension TokenSendCTACollectionViewCell {
    
    func updateButton(with title: String) {
        
        var configuration = UIButton.Configuration.plain()
        configuration.title = title
        configuration.image = .init(named: "dashboard-charging-station")
        configuration.imagePadding = Theme.constant.padding * 0.5
        networkFeeButton.configuration = configuration
        networkFeeButton.updateConfiguration()
    }
    
    @objc func changeNetworkFee() {
        
        presenter.handle(.feeTapped)
    }
}
