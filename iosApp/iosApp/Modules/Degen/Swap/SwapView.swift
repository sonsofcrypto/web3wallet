// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SwapView: AnyObject {

    func update(with viewModel: SwapViewModel)
}

final class SwapViewController: BaseViewController {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var fromInputView: SwapInputView!
    @IBOutlet weak var toInputView: SwapInputView!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var swapButton: UIButton!
    
    var presenter: SwapPresenter!

    private var viewModel: SwapViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func SwapAction(_ sender: Any) {

    }
}

// MARK: - WalletsView

extension SwapViewController: SwapView {

    func update(with viewModel: SwapViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        fromInputView.update(with: viewModel.fromInput)
        toInputView.update(with: viewModel.toInput)
        rateLabel.text = viewModel.rate
    }
}

// MARK: - Configure UI

extension SwapViewController {
    
    func configureUI() {
        (view as? GradientView)?.colors = [
            Theme.colour.backgroundBaseSecondary,
            Theme.colour.backgroundBasePrimary
        ]

        container.backgroundColor = Theme.colour.backgroundBaseSecondary
        container.layer.applyRectShadow()
        container.layer.applyBorder()
        container.layer.applyHighlighted(false)

        rateLabel.font = Theme.font.caption2
        rateLabel.textColor = Theme.colour.labelTertiary

        swapButton.setTitle(Localized("swap"), for: .normal)
    }
}
