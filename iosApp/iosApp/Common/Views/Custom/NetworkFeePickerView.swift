// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct NetworkFeePickerViewModel {
    let estimatedFee: String
    let feeType: FeeType
    
    enum FeeType {
        case low
        case medium
        case high
    }
}

final class NetworkFeePickerView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var networkTokenIcon: UIImageView!
    @IBOutlet weak var networkEstimateFeeLabel: UILabel!
    @IBOutlet weak var networkFeeButton: Button!
    
    private var handler: (() -> Void)!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.apply(style: .footnote)
        nameLabel.text = Localized("currencySwap.cell.estimatedFee")
        networkTokenIcon.image = "send-ethereum-token".assetImage
        networkEstimateFeeLabel.font = Theme.font.footnote
        networkEstimateFeeLabel.textColor = Theme.colour.labelPrimary
        networkFeeButton.style = .secondarySmall(
            leftImage: "dashboard-charging-station".assetImage
        )
        networkFeeButton.addTarget(self, action: #selector(changeNetworkFee), for: .touchUpInside)
    }
}

extension NetworkFeePickerView {
    
    func update(
        with viewModel: NetworkFeePickerViewModel,
        handler: @escaping () -> Void
    ) {
        self.handler = handler
        // TODO: @Annon - to reenable when working
        //networkEstimateFeeLabel.text = viewModel.estimatedFee
        networkTokenIcon.isHidden = true
        networkEstimateFeeLabel.text = "🤷🏻‍♂️"
        switch viewModel.feeType {
        case .low: networkFeeButton.setTitle(Localized("low"), for: .normal)
        case .medium: networkFeeButton.setTitle(Localized("medium"), for: .normal)
        case .high: networkFeeButton.setTitle(Localized("high"), for: .normal)
        }
    }
}

private extension NetworkFeePickerView {
    
    @objc func changeNetworkFee() { handler() }
}
