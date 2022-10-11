// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ImprovementProposalViewController: BaseViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var statusView: CultProposalStatus!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var voteButton: Button!

    var presenter: ImprovementProposalPresenter!

    private var viewModel: ImprovementProposalViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
}

extension ImprovementProposalViewController: ImprovementProposalView {
    
    func update(viewModel_ viewModel: ImprovementProposalViewModel) {
        self.viewModel = viewModel
        imageView.load(url: viewModel.imageUrl)
        title = viewModel.name
        statusView.label.text = viewModel.status
        infoLabel.text = viewModel.body
    }
    
    @IBAction func voteAction(_ sender: UIButton?) {
        presenter.handle(event_____: .Vote())
    }
    
    @objc func dismissAction() {
        presenter.handle(event_____: .Dismiss())
    }
}

private extension ImprovementProposalViewController {
    
    func configureUI() {
        voteButton.style = .primary
        voteButton.setTitle(Localized("proposal.button.vote"), for: .normal)
        stackView.spacing = Theme.constant.padding.half
        stackView.superview?.backgroundColor = Theme.colour.cellBackground
        stackView.superview?.layer.cornerRadius = Theme.constant.cornerRadius
        imageView.layer.cornerRadius = Theme.constant.cornerRadius
        subtitleLabel.apply(style: .headline, weight: .bold)
        subtitleLabel.text = Localized("proposal.summary.header")
        infoLabel.apply(style: .body)
        statusView.label.apply(style: .headline)
        statusView.backgroundColor = Theme.colour.navBarTint
    }
}
