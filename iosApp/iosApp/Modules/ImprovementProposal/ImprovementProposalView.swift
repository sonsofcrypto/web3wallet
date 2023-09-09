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
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var voteButton: Button!

    var presenter: ImprovementProposalPresenter!

    private var viewModel: ImprovementProposalViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
}

extension ImprovementProposalViewController {
    
    func update(with viewModel: ImprovementProposalViewModel) {
        self.viewModel = viewModel
        imageView.setImage(url: viewModel.imageUrl)
        title = viewModel.name
        statusView.label.text = viewModel.status

        if var attrBody = try? AttributedString(markdown: viewModel.body) {
            attrBody.font = Theme.font.body
            attrBody.foregroundColor = Theme.color.textPrimary
            bodyTextView.attributedText = NSAttributedString(attrBody)
        }
    }
    
    @IBAction func voteAction(_ sender: UIButton?) {
        presenter.handle(event: .Vote())
    }
    
    @objc func dismissAction() {
        presenter.handle(event: .Dismiss())
    }
}

private extension ImprovementProposalViewController {
    
    func configureUI() {
        voteButton.style = .primary
        voteButton.setTitle(Localized("proposal.button.vote"), for: .normal)
        stackView.spacing = Theme.padding.half
        stackView.superview?.backgroundColor = Theme.color.bgPrimary
        stackView.superview?.layer.cornerRadius = Theme.cornerRadius
        imageView.layer.cornerRadius = Theme.cornerRadius
        subtitleLabel.apply(style: .headline, weight: .bold)
        subtitleLabel.text = Localized("proposal.summary.header")
        bodyTextView.font = Theme.font.body
        bodyTextView.textColor = Theme.color.textPrimary
        bodyTextView.textContainerInset = .init(top: 0, left: -4, bottom: 0, right: -4)
        statusView.label.apply(style: .headline)
        statusView.backgroundColor = Theme.color.navBarTint
    }
}
