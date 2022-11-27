// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DashboardHeaderTitleView: UICollectionReusableView {
    private lazy var label = UILabel()
    private lazy var rightAction = UILabel()
    private lazy var lineView = LineView()
    private lazy var stack = HStackView(
        [label, UIView(), rightAction],
        spacing: Theme.constant.padding
    )
    
    private var handler: (()->Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.frame = CGRect(
            origin: CGPoint(x: 0, y: (Theme.type.isThemeIOS ? bounds.maxY + 4 : bounds.maxY - 0.5)),
            size: CGSize(width: bounds.width * (Theme.type.isThemeIOS ? 1 : 1.1), height: 0.33)
        )
    }
}

private extension DashboardHeaderTitleView {
    
    func configureUI() {
        label.font = Theme.font.networkTitle
        label.textColor = Theme.colour.labelPrimary
        // TODO: This should be button of certain type
        rightAction.font = Theme.font.body
        rightAction.textColor = Theme.colour.labelPrimary
        rightAction.isHidden = true
        rightAction.add(.targetAction(.init(target: self, selector: #selector(moreTapped))))
        let offset = Theme.type.isThemeIOS ? 0 : -Theme.constant.padding.half + 1
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.contraintToSuperView(bottom: offset)
        addSubview(lineView)
    }
    
    @objc func moreTapped() {
        handler?()
    }
}

// MARK: - ViewModel

extension DashboardHeaderTitleView {

    @discardableResult
    func update(
        with viewModel: DashboardViewModel.SectionHeaderTitle?,
        handler: @escaping () -> Void
    ) -> Self {
        self.handler = handler
        label.text = viewModel?.title.uppercased()
        rightAction.text = viewModel?.action
        rightAction.isHidden = viewModel?.action == nil
        return self
    }
}
