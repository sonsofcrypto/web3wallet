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
        applyTheme(Theme)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyTheme(Theme)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

}

private extension SegmentedControl {
    
    func applyTheme(_ theme: ThemeProtocol) {
        let font = theme.font.footnote
        setTitleTextAttributes(
            [.font: font, .foregroundColor: Theme.color.textPrimary],
            for: .normal
        )
        setTitleTextAttributes(
            [.font: font, .foregroundColor: Theme.color.textPrimary],
            for: .selected
        )

        guard theme.id != .vanilla else {
            setBackgroundImage(nil, for: .normal, barMetrics: .default)
            setBackgroundImage(nil, for: .selected, barMetrics: .default)
            setDividerImage(
                nil,
                forLeftSegmentState: .normal,
                rightSegmentState: .normal,
                barMetrics: .default
            )
            return
        }

        setBackgroundImage(
            Theme.color.bgSecondary.image(),
            for: .normal,
            barMetrics: .default
        )
        setBackgroundImage(
            Theme.color.bgPrimary.image(),
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
