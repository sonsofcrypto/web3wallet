// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ImprovementProposalViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var presenter: ImprovementProposalPresenter!

    private var viewModel: ImprovementProposalViewModel?
    private var titleUpdateEnabled = false
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleUpdateEnabled = true
        updateTitle()
    }
}

extension ImprovementProposalViewController: ImprovementProposalView {

    func update(viewModel_ viewModel: ImprovementProposalViewModel) {
        self.viewModel = viewModel
        updateTitle()
        collectionView.reloadData()
        scrollToSelectedItem()
    }
}

extension ImprovementProposalViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.proposals.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeue(
            ImprovementProposalCell.self,
            for: indexPath
        ).update(
            with: viewModel?.proposals[indexPath.item],
            handler: { [weak self] in self?.voteAction(indexPath) }
        )
    }
}

extension ImprovementProposalViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard titleUpdateEnabled else { return }
        updateTitle()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        titleUpdateEnabled = true
        updateTitle()
        scrollToTop()
    }
}

private extension ImprovementProposalViewController {

    func scrollToTop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.setContentOffset(
                self.collectionView.contentOffset.pointWithY(
                    -self.view.safeAreaInsets.top
                ),
                animated: true
            )
        }
    }

    func scrollToSelectedItem() {
        // NOTE: Dispatching async so that scrollView has time to reload
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(
                at: .init(item: Int(self.viewModel?.selectedIdx ?? 0), section: 0),
                at: [.top, .centeredHorizontally],
                animated: false
            )
        }
    }

    func updateTitle() {
        let idx = collectionView.indexPathsForVisibleItems.first?.item ?? 0
        let count = viewModel?.proposals.count ?? 0
        title = Localized("proposal.title", idx, count - 1)
    }

    func voteAction(_ idxPath: IndexPath) {
        presenter.handle(event_____: .Vote(idx: Int32(idxPath.item)))
    }
    
    @objc func dismissAction() {
        presenter.handle(event_____: .Dismiss())
    }

    func configureUI() {
        collectionView.setCollectionViewLayout(layout(), animated: false)
    }

    func layout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .fractional(estimatedH: 100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .fractional(estimatedH: 100), subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return UICollectionViewCompositionalLayout(section: section)
    }
}
