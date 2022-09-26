// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ProposalsView: AnyObject {
    func update(with viewModel: ProposalsViewModel)
}

final class ProposalsViewController: BaseViewController {
    //let searchController = UISearchController()
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()

    var presenter: ProposalsPresenter!

    private var viewModel: ProposalsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension ProposalsViewController: ProposalsView {

    func update(with viewModel: ProposalsViewModel) {
        self.viewModel = viewModel
        title = viewModel.title

        switch viewModel {
        case .loading:
            showLoading()
        case .loaded:
            hideLoading()
            collectionView.reloadData()
            refreshControl.endRefreshing()
        case .error:
            hideLoading()
            //showError()
        }
    }
}

extension ProposalsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.sections[section].items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let section = viewModel.sections[indexPath.section]
        let viewModel = section.items[indexPath.item]
        let cell = collectionView.dequeue(ProposalsCell.self, for: indexPath)
        let idx = indexPath.item
        return cell.update(
            with: viewModel,
            handler: { [weak self] in self?.presenter.handle(.vote(idx: idx)) }
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
                withReuseIdentifier: String(describing: ProposalsHeaderSupplementaryView.self),
                for: indexPath
            ) as? ProposalsHeaderSupplementaryView else {
                
                return ProposalsHeaderSupplementaryView()
            }
            
            let section = viewModel.sections[indexPath.section]
            headerView.update(with: section)
            return headerView
            
        default:
            assertionFailure("Unexpected element kind: \(kind).")
            return UICollectionReusableView()
        }
    }
}

extension ProposalsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.handle(.select(idx: indexPath.item))
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        searchController.searchBar.resignFirstResponder()
//    }
}

private extension ProposalsViewController {
    
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
            withTitle: Localized("proposals.segmentedControl.infrastructure"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("proposals.segmentedControl.integrations"),
            at: 1,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("proposals.segmentedControl.features"),
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
        presenter.handle(.didSelectCategory(idx: sender.selectedSegmentIndex))
    }
    
    func configureUI() {
        edgesForExtendedLayout = []
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(dimissTapped)
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
            ProposalsHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: String(describing: ProposalsHeaderSupplementaryView.self)
        )
        refreshControl.tintColor = Theme.colour.activityIndicator
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
    }
    
    @objc func dimissTapped() {
        presenter.handle(.dismiss)
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
