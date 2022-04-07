//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class DashboardHeaderView: UICollectionReusableView {

    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var firstSectionLabel: UILabel!
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet weak var buttonsStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        balance.textColor = AppTheme.current.colors.textColor
        balance.font = AppTheme.current.fonts.hugeBalance
        containerStack.setCustomSpacing(
            Constant.sectionTitleOffset,
            after: buttonsStack
        )
        buttonsStack.arrangedSubviews.forEach {
            ($0 as? UIButton)?.tintColor = AppTheme.current.colors.tintSecondary
            ($0 as? UIButton)?.titleLabel?.font = AppTheme.current.fonts.mediumButton
            ($0 as? UIButton)?.layer.cornerRadius = Global.cornerRadius / 2
            ($0 as? UIButton)?.titleLabel?.textAlignment = .center
        }
        (receiveButton as? LeftImageButton)?.titleLabelXOffset = 0
        firstSectionLabel.applyStyle(.callout)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        buttonsStack.arrangedSubviews.forEach {
            ($0 as? UIButton)?.removeAllTargets()
        }
    }
}

// MARK: - DashboardViewModel

extension DashboardHeaderView {

    func update(with viewModel: DashboardViewModel.Header?) {
        balance.text =  viewModel?.balance
        firstSectionLabel.text = viewModel?.firstSection
        [receiveButton, sendButton, tradeButton].enumerated().forEach {
            let btnViewModel = viewModel?.buttons[$0.0]
            $0.1?.setTitle(btnViewModel?.title ?? "", for: .normal)
            $0.1?.setImage(UIImage(named: btnViewModel?.imageName ?? ""), for: .normal)
        }
    }
}


// MARK: - Constant

extension DashboardHeaderView {

    enum Constant {
        static let sectionTitleOffset: CGFloat = 27
    }
}
