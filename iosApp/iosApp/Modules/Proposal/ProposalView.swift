// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ProposalView: AnyObject {
    func update(with viewModel: ProposalViewModel)
}

final class ProposalViewController: BaseViewController {
    var presenter: ProposalPresenter!
    
    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: ProposalViewModel!
    private var endDisplayFirstTimeCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
}

extension ProposalViewController: ProposalView {

    func update(with viewModel: ProposalViewModel) {
        self.viewModel = viewModel
        setTitle(with: viewModel.selectedIndex + 1)
        collectionView.reloadData()
        scrollToSelectedItem()
    }
}

extension ProposalViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.details.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let viewModel = viewModel.details[indexPath.item]
        let cell = collectionView.dequeue(ProposalDetailViewCell.self, for: indexPath)
        return cell.update(with: viewModel, handler: proposalDetailViewHandler())
    }
}

extension ProposalViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        // NOTE: Adding a flag here since will display gets called a few times before scrolling
        // to the selected item without an animation and this causes the navigation bar title
        // to change
        guard endDisplayFirstTimeCalled else { return }
        setTitle(with: indexPath.item + 1)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        endDisplayFirstTimeCalled = true
        guard let visibleCell = collectionView.visibleCells.first else {
            scrollToTop()
            return
        }
        guard let currentIndexPath = collectionView.indexPath(for: visibleCell) else { return }
        setTitle(with: currentIndexPath.item + 1)
        scrollToTop()
    }
}

private extension ProposalViewController {
    
    func scrollToTop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollRectToVisible(
                .init(origin: .init(x: 0, y: 0), size: self.collectionView.visibleSize),
                animated: true
            )
        }
    }
    
    func scrollToSelectedItem() {
        // NOTE: Dispatching async otherwise the scroll does not position the view
        // properly
        DispatchQueue.main.async {
            [weak self] in
            guard let self = self else { return }
            self.collectionView.scrollToItem(
                at: .init(item: self.viewModel.selectedIndex, section: 0),
                at: .centeredHorizontally,
                animated: false
            )
        }
    }
    
    func setTitle(with index: Int) {
        title = viewModel.title + " \(index) " + Localized("proposal.title.of") + " \(viewModel.details.count)"
    }
    
    func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
        collectionView.setCollectionViewLayout(compositionalLayout(), animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.clipsToBounds = false
    }
    
    @objc func dismissTapped() {
        presenter.handle(.dismiss)
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(section: collectionLayoutSection())
    }
  
    func collectionLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        //section.interGroupSpacing = Theme.constant.padding * 0.25
        return section
    }
}

private extension ProposalViewController {

    func proposalDetailViewHandler() -> ProposalDetailViewCell.Handler {
        .init(onVote: onVote())
    }
    
    func onVote() -> (String) -> Void {
        { [weak self] id in self?.presenter.handle(.vote(id: id)) }
    }
}
