// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderView: UICollectionReusableView {
    
    private weak var presenter: DashboardPresenter?

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
        
        balance.textColor = ThemeOG.color.text
        balance.font = ThemeOG.font.hugeBalance
        containerStack.setCustomSpacing(
            Constant.sectionTitleOffset,
            after: buttonsStack
        )
        buttonsStack.arrangedSubviews.forEach {
            ($0 as? UIButton)?.tintColor = ThemeOG.color.tintSecondary
            ($0 as? UIButton)?.titleLabel?.font = ThemeOG.font.mediumButton
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

extension DashboardHeaderView {

    func update(
        with viewModel: DashboardViewModel.Header?,
        presenter: DashboardPresenter?
    ) {
        
        self.presenter = presenter
        
        balance.text =  viewModel?.balance
        
        firstSectionLabel.text = viewModel?.firstSection
        
        [receiveButton, sendButton, tradeButton].enumerated().forEach {
            let btnViewModel = viewModel?.buttons[$0.0]
            $0.1?.setTitle(btnViewModel?.title ?? "", for: .normal)
            $0.1?.setImage(UIImage(named: btnViewModel?.imageName ?? ""), for: .normal)
        }
    }
}

private extension DashboardHeaderView {

    func addActions(for supplementary: DashboardHeaderView) {
        
        receiveButton.addTarget(
            self,
            action: #selector(receiveAction(_:)),
            for: .touchUpInside
        )
        sendButton.addTarget(
            self,
            action: #selector(sendAction(_:)),
            for: .touchUpInside
        )
        tradeButton.addTarget(
            self,
            action: #selector(tradeAction(_:)),
            for: .touchUpInside
        )
    }
    
    @IBAction func receiveAction(_ sender: Any) {
        
        presenter?.handle(.receiveAction)
    }
    
    @IBAction func sendAction(_ sender: Any) {
        
        presenter?.handle(.sendAction)
    }
    
    @IBAction func tradeAction(_ sender: Any) {
        
        presenter?.handle(.tradeAction)
    }
}

extension DashboardHeaderView {

    enum Constant {
        static let sectionTitleOffset: CGFloat = 28
    }
}
