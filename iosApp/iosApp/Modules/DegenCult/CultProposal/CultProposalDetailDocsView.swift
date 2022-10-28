// Created by web3d3v on 24/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

final class CultProposalDetailDocsView: UIView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var docsStackView: UIStackView!
    
    private var directory = [Int: String]()
    private var directoryIndex = 1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = Theme.colour.cellBackground
        layer.cornerRadius = Theme.constant.cornerRadius
        titleLabel.apply(style: .headline, weight: .bold)
        separatorView.backgroundColor = Theme.colour.separatorTransparent
        stackView.setCustomSpacing(Theme.constant.padding * 0.75, after: titleLabel)
        stackView.setCustomSpacing(Theme.constant.padding * 0.75, after: separatorView)
    }
    
    func update(
        with documentsInfo: CultProposalViewModel.ProposalDetails.DocumentsInfo
    ) {
        titleLabel.text = documentsInfo.title
        docsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        resetDirectory()
        documentsInfo.documents.forEach {
            docsStackView.addArrangedSubview(
                makeDocumentInfoView(from: $0)
            )
        }
    }
}

private extension CultProposalDetailDocsView {
    
    func makeDocumentInfoView(
        from documentInfo: CultProposalViewModel.ProposalDetails.DocumentsInfo.Document
    ) -> UIView {
        var views = [UIView]()
        let titleLabel = UILabel()
        titleLabel.apply(style: .subheadline)
        titleLabel.textColor = Theme.colour.labelSecondary
        titleLabel.text = documentInfo.title
        views.append(titleLabel)
        documentInfo.items.forEach {
            views.append(makeDocumentView(from: $0))
        }
        let vStack = VStackView(views)
        vStack.spacing = Theme.constant.padding * 0.25
        return vStack
    }
    
    func makeDocumentView(
        from item: CultProposalViewModel.ProposalDetails.DocumentsInfo.Document.Item
    ) -> UIView {
        switch item {
        case let .link(displayName, url):
            let name = UILabel()
            name.apply(style: .subheadline)
            name.textColor = Theme.colour.navBarTint
            name.text = displayName
            name.numberOfLines = 0
            let tag = addLinkToDirectory(url: url)
            name.tag = tag
            name.add(.targetAction(.init(target: self, selector: #selector(documentTapped(sender:)))))
            return name
        case let .note(note):
            let name = UILabel()
            name.apply(style: .subheadline)
            name.text = note
            name.numberOfLines = 0
            return name
        }
    }

    func resetDirectory() {
        directoryIndex = 1
        directory = [:]
    }
    
    func addLinkToDirectory(url: String) -> Int {
        let directoryIndex = directoryIndex
        directory[directoryIndex] = url
        self.directoryIndex += 1
        return directoryIndex
    }
    
    @objc func documentTapped(sender: UITapGestureRecognizer) {
        guard let tag = sender.view?.tag else { return }
        guard let url = directory[tag]?.url else { return }
        UIApplication.shared.open(url)
    }
}
