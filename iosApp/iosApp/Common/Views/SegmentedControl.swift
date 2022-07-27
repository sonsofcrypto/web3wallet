// Created by web3d4v on 19/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class SegmentedControl: UISegmentedControl {
    
    convenience init() {
        
        let windowWidth = SceneDelegateHelper().window?.frame.width ?? 0
        
        let frame: CGRect = .init(
            origin: .zero,
            size: .init(width: windowWidth * 0.6, height: 32)
        )

        self.init(frame: frame)
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

private extension SegmentedControl {
    
    func configureUI() {
        
        setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Theme.font.footnote,
                NSAttributedString.Key.foregroundColor: Theme.colour.segmentedControlText
            ],
            for: .normal
        )
        setTitleTextAttributes(
            [
                NSAttributedString.Key.font: Theme.font.footnote,
                NSAttributedString.Key.foregroundColor: Theme.colour.segmentedControlTextSelected
            ],
            for: .selected
        )

        setBackgroundImage(
            Theme.colour.segmentedControlBackground.image(),
            for: .normal,
            barMetrics: .default
        )
        setBackgroundImage(
            Theme.colour.segmentedControlBackgroundSelected.image(),
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
