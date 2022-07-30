// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class ProposalVoteView: UIView {
    
    struct ViewModel {
        
        let name: String
        let value: Double
        let total: Double
        let type: `Type`
        
        enum `Type` {
            
            case approved
            case rejected
        }
    }

    // From 0.0 - 1.0
    private(set) var progress: Float = 0.5 {
        didSet { setNeedsLayout() }
    }

    private weak var progressView: UIView!
    private weak var stack: UIStackView!
    private weak var textLabel: UILabel!
    private weak var pctLabel: UILabel!
    
    func update(viewModel: ViewModel) {
        
        if textLabel == nil { configureUI() }
        
        textLabel.text = viewModel.name
        pctLabel.text = NumberFormatter.pct.string(
            from: Float(viewModel.value)
        )
        progress = Float(viewModel.value)
        
        switch viewModel.type {
            
        case .approved:
            progressView.backgroundColor = Theme.colour.candleGreen
        case .rejected:
            progressView.backgroundColor = Theme.colour.candleRed
        }
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        stack.frame = bounds.insetBy(dx: Theme.constant.padding, dy: 0)
        
        progressView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: bounds.width * CGFloat(progress),
                height: bounds.height
            )
        )
    }
}

extension ProposalVoteView {
    
    func configureUI() {
        
        backgroundColor = Theme.colour.fillQuaternary
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        let textLabel = UILabel(with: .callout)
        self.textLabel = textLabel
        
        let pctLabel = UILabel(with: .callout)
        self.pctLabel = pctLabel
        
        let stack = HStackView([textLabel, pctLabel])
        self.stack = stack
        addSubview(stack)

        let view = UIView(frame: bounds)
        view.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        self.progressView = view
        insertSubview(view, at: 0)
    }
}
