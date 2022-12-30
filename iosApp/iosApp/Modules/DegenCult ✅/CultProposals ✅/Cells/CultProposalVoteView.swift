// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class CultProposalVoteView: UIView {

    // From 0.0 - 1.0
    private(set) var progress: Float = 0.5 {
        didSet { setNeedsLayout() }
    }
    private lazy var textLabel: UILabel = UILabel(with: .callout)
    private lazy var pctLabel: UILabel = UILabel(with: .callout)
    private lazy var progressView: UIView = {
        let view = UIView(frame: bounds)
        view.layer.cornerRadius = Theme.cornerRadiusSmall
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
        backgroundColor = Theme.color.bgPrimary
        layer.cornerRadius = Theme.cornerRadiusSmall
    }

    func update(viewModel: CultProposalsViewModel.Vote, progressColor: UIColor) {
        textLabel.text = viewModel.name
        pctLabel.text = NumberFormatter.pct.string(from: Float(viewModel.value))
        progress = Float(viewModel.value)
        progressView.backgroundColor = progressColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        stack.frame = bounds.insetBy(dx: Theme.padding, dy: 0)
        progressView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: bounds.width * CGFloat(progress),
                height: bounds.height
            )
        )
    }
}
