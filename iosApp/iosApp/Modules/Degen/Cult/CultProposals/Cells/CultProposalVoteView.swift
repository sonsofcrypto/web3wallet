// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CultProposalVoteView: UIView {

    // From 0.0 - 1.0
    private(set) var progress: Float = 0.5 {
        didSet { setNeedsLayout() }
    }

    private lazy var textLabel: UILabel = UILabel(with: .smallLabel)
    private lazy var pctLabel: UILabel = UILabel(with: .smallLabel)

    private lazy var progressView: UIView = {
        let view = UIView(frame: bounds)
        view.backgroundColor = Theme.colour.fillTertiary
        view.layer.applyBorder(Theme.colour.fillTertiary)
        view.layer.cornerRadius = Global.cornerRadius
        insertSubview(view, at: 0)
        return view
    }()

    private lazy var stack: UIStackView = {
        let stack = HStackView([textLabel, pctLabel])
        addSubview(stack)
        return stack
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Theme.colour.backgroundBaseSecondary
        layer.applyBorder(Theme.colour.fillTertiary)
        layer.cornerRadius = Global.cornerRadius
    }

    func update(title: String, pct: Float) {
        textLabel.text = title
        pctLabel.text = NumberFormatter.pct.string(from: pct)
        progress = pct
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stack.frame = bounds.insetBy(dx: Global.padding, dy: 0)
        progressView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: bounds.width * CGFloat(progress),
                height: bounds.height
            )
        )
    }
}
