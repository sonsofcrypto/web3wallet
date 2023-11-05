// Created by web3d4v on 19/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class SegmentedControl: UISegmentedControl {
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureUI()
    }

}

private extension SegmentedControl {
    
    func configureUI() {
        setTitleTextAttributes(
            [
                .font: Theme.font.footnote,
                .foregroundColor: Theme.color.segmentedControlText
            ],
            for: .normal
        )
        setTitleTextAttributes(
            [
                .font: Theme.font.footnote,
                .foregroundColor: Theme.color.segmentedControlTextSelected
            ],
            for: .selected
        )

        setBackgroundImage(
            Theme.color.segmentedControlBackground.image(),
            for: .normal,
            barMetrics: .default
        )
        setBackgroundImage(
            Theme.color.segmentedControlBackgroundSelected.image(),
            for: .selected,
            barMetrics: .default
        )
        setDividerImage(
            UIColor.clear.image(),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .default
        )
    }
}

extension UISegmentedControl {
    var selectedIdx: Int { selectedSegmentIndex }
}