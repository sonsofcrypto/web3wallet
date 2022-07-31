// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderNameView: UICollectionReusableView {
        
    private weak var label: UILabel!
    private weak var fuelCostImageView: UIView!
    private weak var fuelCostLabel: UILabel!
    private weak var rightAction: UILabel!
    
    private var handler: Handler?
    
    struct Handler {
        
        let onMoreTapped: () -> Void
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
}

private extension DashboardHeaderNameView {
    
    func configureUI() {
        
        let label = UILabel()
        label.font = Theme.font.networkTitle
        label.textColor = Theme.colour.labelPrimary
        self.label = label
        label.addConstraints(
            [
                .hugging(layoutAxis: .horizontal, priority: .required)
            ]
        )
        
        let iconImageViewGroup = UIView()
        iconImageViewGroup.backgroundColor = .clear
        let iconImageView = UIImageView(
            image: "dashboard-charging-station".assetImage!
        )
        iconImageViewGroup.addSubview(iconImageView)
        iconImageView.addConstraints(
            [
                .layout(anchor: .leadingAnchor),
                .layout(anchor: .trailingAnchor),
                .layout(anchor: .centerYAnchor, constant: .equalTo(constant: -2)),
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 14)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 14))
            ]
        )
        self.fuelCostImageView = iconImageViewGroup
        
        let fuelCostLabel = UILabel()
        fuelCostLabel.font = Theme.font.dashboardSectionFuel
        fuelCostLabel.textColor = Theme.colour.labelPrimary
        self.fuelCostLabel = fuelCostLabel
        
        let groupView = HStackView(
            [label, iconImageViewGroup, fuelCostLabel],
            spacing: Theme.constant.padding.half
        )
        addSubview(groupView)
        groupView.setCustomSpacing(Theme.constant.padding, after: label)
        
        groupView.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding * 0.5)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 30))
            ]
        )
        
        let rightAction = UILabel()
        rightAction.font = Theme.font.body
        rightAction.textColor = Theme.colour.labelPrimary
        rightAction.isHidden = true
        rightAction.add(.targetAction(.init(target: self, selector: #selector(moreTapped))))
        self.rightAction = rightAction
        addSubview(rightAction)
        rightAction.addConstraints(
            [
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .centerYAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 30))
            ]
        )
        
        let view = UIView()
        view.backgroundColor = Theme.colour.labelPrimary
        addSubview(view)
        view.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding * 0.5)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: -Theme.constant.padding)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 0.3)),
                .layout(anchor: .bottomAnchor)
            ]
        )
    }
    
    @objc func moreTapped() {
        
        handler?.onMoreTapped()
    }
}

extension DashboardHeaderNameView {

    func update(
        with title: String,
        and network: DashboardViewModel.Section.Header.Network?,
        handler: Handler?
    ) {
        
        self.handler = handler
        
        label.text = title.uppercased()
        
        guard let network = network else {
            
            rightAction.isHidden = true
            fuelCostImageView.isHidden = true
            fuelCostLabel.isHidden = true
            return
        }
        
        rightAction.isHidden = false
        rightAction.text = network.rightActionTitle
        
        fuelCostImageView.isHidden = false
        fuelCostLabel.isHidden = false
        fuelCostLabel.text = network.fuelCost
    }
}
