// Created by web3d4v on 19/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SegmentedControl: UISegmentedControl {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
}

private extension SegmentedControl {
    
    func configureUI() {
        
        setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Theme.font.footnote,
                NSAttributedString.Key.foregroundColor: Theme.colour.labelPrimary
            ],
            for: .normal
        )

        setBackgroundImage(
            Theme.colour.fillQuaternary.image(),
            for: .normal,
            barMetrics: .default
        )
        setBackgroundImage(
            Theme.colour.fillTertiary.image(),
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
