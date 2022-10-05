// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ImprovementProposalsViewController: BaseViewController {
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()

    var presenter: ImprovementProposalsPresenter!

    private var viewModel: ImprovementProposalsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension ImprovementProposalsViewController: ImprovementProposalsView {

    func update(viewModel: ImprovementProposalsViewModel) {
        self.viewModel = viewModel
        print("=== ", viewModel)
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
        case "header":
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: ImprovementProposalsHeaderSupplementaryView.self),
                for: indexPath
            ) as? ImprovementProposalsHeaderSupplementaryView else {
                return ImprovementProposalsHeaderSupplementaryView()
            }
             headerView.update(with: viewModel?.selectedCategory())
            return headerView
        default:
            assertionFailure("Unexpected element kind: \(kind).")
            return UICollectionReusableView()
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

    func handle(_ alertAction: UIAlertAction) {
        presenter.handle(event____: .AlertAction(idx: 0))
    }
}

private extension ImprovementProposalsViewController {
    
    func showLoading() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
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
        segmentContainer.addSubview(segmentControl)
        segmentControl.addConstraints(
            [
                .layout(anchor: .centerYAnchor),
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                )
            ]
        )
    }
    
    @objc func segmentControlChanged(_ sender: SegmentedControl) {
        presenter.handle(
            event____: .Category(idx: Int32(sender.selectedSegmentIndex))
        )
    }
    
    func configureUI() {
        edgesForExtendedLayout = []
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dismissAction)
        )
        topContainerView.backgroundColor = Theme.colour.navBarBackground
        setSegmented()
        activityIndicator.color = Theme.colour.activityIndicator
        collectionView.setCollectionViewLayout(
            compositionalLayout(),
            animated: false
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        collectionView.register(
            ImprovementProposalsHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: String(describing: ImprovementProposalsHeaderSupplementaryView.self)
        )
        refreshControl.tintColor = Theme.colour.activityIndicator
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
    }
    
    @objc func dismissAction() {
        presenter.handle(event____: .Dismiss())
    }
    
    @objc func didPullToRefresh(_ sender: Any) {
        presenter.present()
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
            elementKind: "header",
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

//extension FeaturesViewController: UISearchResultsUpdating {
//
//    func updateSearchResults(for searchController: UISearchController) {
//
//        guard let text = searchController.searchBar.text else { return }
//
//        presenter.handle(.filterBy(text: text))
//    }
//}
