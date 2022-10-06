// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ImprovementProposalsViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    var presenter: ImprovementProposalsPresenter!

    private var viewModel: ImprovementProposalsViewModel?
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension ImprovementProposalsViewController: ImprovementProposalsView {

    func update(viewModel: ImprovementProposalsViewModel) {
        self.viewModel = viewModel
        if let loading = viewModel as? ImprovementProposalsViewModel.Loading {
            refreshControl.beginRefreshing()
        }
        if let error = viewModel as? ImprovementProposalsViewModel.Error {
            refreshControl.endRefreshing()
            let alert = UIAlertController(
                error.error,
                handlers: [{ [weak self] action in self?.handle(action) }]
            )
            present(alert, animated: true)
        }
        if let loaded = viewModel as? ImprovementProposalsViewModel.Loaded {
            refreshControl.endRefreshing()
            collectionView.reloadData()
        }
    }
}

extension ImprovementProposalsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.selectedCategory()?.items.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        collectionView.dequeue(ImprovementProposalsCell.self, for: indexPath)
            .update(
                with: viewModel?.selectedCategory()?.items[indexPath.item],
                handler: { [weak self] in self?.voteAction(idx: indexPath.item) }
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeue(
                SectionHeaderView.self,
                for: indexPath,
                kind: .header
            ).update(with: viewModel?.selectedCategory())
        default:
            fatalError("Unexpected element kind: \(kind).")
        }
    }
}

extension ImprovementProposalsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.handle(event____: .Proposal(idx: Int32(indexPath.item)))
    }

    func voteAction(idx: Int) {
        presenter.handle(event____: .Vote(idx: Int32(idx)))
    }

    @objc func segmentControlChanged(_ sender: SegmentedControl) {
        presenter.handle(
            event____: .Category(idx: Int32(sender.selectedSegmentIndex))
        )
    }

    @objc func refreshAction(_ sender: Any) {
        presenter.present()
    }

    @objc func dismissAction() {
        presenter.handle(event____: .Dismiss())
    }

    func handle(_ alertAction: UIAlertAction) {
        presenter.handle(event____: .AlertAction(idx: 0))
    }
}

private extension ImprovementProposalsViewController {

    func setSegmented() {
        let segmentControl = SegmentedControl()
        segmentControl.insertSegment(
            withTitle: Localized("proposals.infrastructure.title"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("proposals.integrations.title"),
            at: 1,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("proposals.features.title"),
            at: 2,
            animated: false
        )
        
        segmentControl.selectedSegmentIndex = 0
        
        segmentControl.addTarget(
            self,
            action: #selector(segmentControlChanged(_:)),
            for: .valueChanged
        )
//        segmentContainer.addSubview(segmentControl)
//        segmentControl.addConstraints(
//            [
//                .layout(anchor: .centerYAnchor),
//                .layout(
//                    anchor: .leadingAnchor,
//                    constant: .equalTo(constant: Theme.constant.padding)
//                ),
//                .layout(
//                    anchor: .trailingAnchor,
//                    constant: .equalTo(constant: Theme.constant.padding)
//                )
//            ]
//        )
    }
    

    
    func configureUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            with: .init(systemName: "xmark"),
            target: self,
            action: #selector(dismissAction)
        )
        setSegmented()
        collectionView.setCollectionViewLayout(layout(), animated: false)
        collectionView.backgroundView = ThemeGradientView()
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
    }
    

    func layout() -> UICollectionViewCompositionalLayout {
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
            widthDimension: .absolute(
                view.frame.size.width - Theme.constant.padding * 2
            ),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: Theme.constant.padding,
            leading: Theme.constant.padding,
            bottom: Theme.constant.padding,
            trailing: Theme.constant.padding
        )
        section.interGroupSpacing = Theme.constant.padding
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
//        let footerItemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1),
//            heightDimension: .estimated(100)
//        )
//        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: footerItemSize,
//            elementKind: "footer",
//            alignment: .bottom
//        )
        section.boundarySupplementaryItems = [headerItem]
        return section
    }
}
