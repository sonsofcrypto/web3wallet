//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

protocol SwapView: AnyObject {

    func update(with viewModel: SwapViewModel)
}

class SwapViewController: UIViewController {

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
            AppTheme.current.colors.background,
            AppTheme.current.colors.backgroundDark
        ]

        container.backgroundColor = AppTheme.current.colors.background
        container.layer.applyRectShadow()
        container.layer.applyBorder()
        container.layer.applyHighlighted(false)

        rateLabel.font = AppTheme.current.fonts.caption2
        rateLabel.textColor = AppTheme.current.colors.textColorTertiary

        swapButton.setTitle(Localized("swap"), for: .normal)
    }
}
