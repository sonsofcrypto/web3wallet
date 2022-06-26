// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalView: AnyObject {

    func update(with viewModel: CultProposalViewModel)
}

class CultProposalViewController: UIViewController {

    var presenter: CultProposalPresenter!

    private var viewModel: CultProposalViewModel?
    
    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

// MARK: - WalletsView

extension CultProposalViewController: CultProposalView {

    func update(with viewModel: CultProposalViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        textView.text = """
                        \(viewModel.title)

                        SUMMARY
                        \(viewModel.summary)
                                    
                        GUARDIAN: 
                        \(viewModel.guardian)
                                    
                        WALLET:
                        \(viewModel.wallet)
                        """
    }
}

// MARK: - Configure UI

extension CultProposalViewController {
    
    func configureUI() {
        (view as? GradientView)?.colors = [
            ThemeOG.color.background,
            ThemeOG.color.backgroundDark
        ]
    }
}
