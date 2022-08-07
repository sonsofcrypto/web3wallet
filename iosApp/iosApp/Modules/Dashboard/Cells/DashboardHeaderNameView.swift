// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderNameView: UICollectionReusableView {
    private lazy var label = UILabel()
    private lazy var fuelCostImageView = UIImageView(named: "charging_station")
    private lazy var fuelCostLabel = UILabel()
    private lazy var rightAction = UILabel()
    private lazy var lineView = LineView()
    private lazy var stack = HStackView(
        [label, fuelCostImageView, fuelCostLabel, UIView(), rightAction],
        spacing: Theme.constant.padding
    )
    
    var btnHandler: (()->Void)?

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
            origin: CGPoint(x: 0, y: bounds.maxY - 0.5),
            size: CGSize(width: bounds.width * 1.1, height: 0.5)
        )
    }
}

private extension DashboardHeaderNameView {
    
    func configureUI() {
        label.font = Theme.font.networkTitle
        label.textColor = Theme.colour.labelPrimary
        
        fuelCostLabel.font = Theme.font.dashboardSectionFuel
        fuelCostLabel.textColor = Theme.colour.labelPrimary
        fuelCostImageView.contentMode = .bottom

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
        lineView.isHidden = Theme.type.isThemeIOS
    }
    
    @objc func moreTapped() {
        btnHandler?()
    }
}

// MARK: - ViewModel

extension DashboardHeaderNameView {

    func update(
        with title: String,
        and network: DashboardViewModel.Section.Header.Network?,
        handler: (()->Void)?
    ) -> Self {
        btnHandler = handler
        label.text = title.uppercased()
        rightAction.text = network?.rightActionTitle ?? ""
        fuelCostLabel.text = network?.fuelCost ?? ""
        [rightAction, fuelCostImageView, fuelCostLabel].forEach {
            $0.isHidden = network == nil
        }
        return self
    }
}
