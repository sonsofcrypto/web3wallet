// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ThemeGradientView: GradientView {

    var topClipEnabled: Bool = false {
        didSet { setTopClipEnabled(topClipEnabled) }
    }

    private weak var topClipView: UIView?

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
        if let topClipView = topClipView {
            topClipView.frame = CGRect(
                zeroOrigin: CGSize(width: bounds.width, height: 20)
            )
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        configureUI()
    }

    private func configureUI() {
        colors = [Theme.color.bgGradientTop, Theme.color.bgGradientBtm]
    }

    private func setTopClipEnabled(_ enabled: Bool) {
        if !enabled {
            topClipView?.removeFromSuperview()
        }
        if enabled && topClipView == nil {
            let view = UIView()
            topClipView = view
            view.backgroundColor = Theme.color.navBarBackground
            addSubview(view)
        }
    }
}
