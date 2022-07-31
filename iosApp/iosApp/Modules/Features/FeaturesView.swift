// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol FeaturesView: AnyObject {

    func update(with viewModel: FeaturesViewModel)
}

final class FeaturesViewController: BaseViewController {
    
    //let searchController = UISearchController()
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var segmentContainer: UIView!
    @IBOutlet weak var dividerLineView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()

    var presenter: FeaturesPresenter!

    private var viewModel: FeaturesViewModel!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.showBottomLine(false)
    }    
}

extension FeaturesViewController: FeaturesView {

    func update(with viewModel: FeaturesViewModel) {
        
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

extension FeaturesViewController: UICollectionViewDataSource {
    
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
        let cell = collectionView.dequeue(FeaturesCell.self, for: indexPath)
        return cell.update(
            with: viewModel,
            handler: makeCultProposalCellPendingHandler()
        )
    }
}

extension FeaturesViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        let section = viewModel.sections[indexPath.section]
        let item = section.items[indexPath.row]
        presenter.handle(.select(id: item.id))
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        searchController.searchBar.resignFirstResponder()
//    }
}

private extension FeaturesViewController {
    
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
            withTitle: Localized("features.segmentedControl.all"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("features.segmentedControl.infrastructure"),
            at: 1,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("features.segmentedControl.integrations"),
            at: 2,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("features.segmentedControl.features"),
            at: 3,
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
        
        let sectionType: FeaturesViewModel.Section.`Type`
        
        switch sender.selectedSegmentIndex {
            
        case 0: sectionType = .all
        case 1: sectionType = .infrastructure
        case 2: sectionType = .integrations
        default: sectionType = .features
        }
        
        return presenter.handle(
            .filterBySection(sectionType: sectionType)
        )
    }
    
    func configureUI() {
        
        topContainerView.backgroundColor = Theme.colour.navBarBackground
        dividerLineView.backgroundColor = navigationController?.bottomLineColor
        
        setSegmented()
        
        activityIndicator.color = Theme.colour.activityIndicator
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        collectionView.register(
            CultProposalHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: String(describing: CultProposalHeaderSupplementaryView.self)
        )
        collectionView.register(
            CultProposalFooterSupplementaryView.self,
            forSupplementaryViewOfKind: "footer",
            withReuseIdentifier: String(describing: CultProposalFooterSupplementaryView.self)
        )
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        
        refreshControl.tintColor = Theme.colour.activityIndicator
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)

//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
    }
    
    @objc func didPullToRefresh(_ sender: Any) {

        presenter.present()
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout(
            section: makeCollectionLayoutSection()
        )
    }
  
    func makeCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(
                view.frame.size.width - Theme.constant.padding * 2
            ),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: Theme.constant.padding * 2,
            leading: Theme.constant.padding,
            bottom: Theme.constant.padding,
            trailing: Theme.constant.padding
        )
        section.interGroupSpacing = Theme.constant.padding * 1.5
        
//        let headerItemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1),
//            heightDimension: .estimated(100)
//        )
//        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerItemSize,
//            elementKind: "header",
//            alignment: .top
//        )
//        let footerItemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1),
//            heightDimension: .estimated(100)
//        )
//        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: footerItemSize,
//            elementKind: "footer",
//            alignment: .bottom
//        )
        
        //section.boundarySupplementaryItems = [headerItem, footerItem]
        
        return section
    }
}

private extension FeaturesViewController {

    func makeCultProposalCellPendingHandler() -> FeaturesCell.Handler {
        
        .init(
            approveProposal: makeApproveProposal(),
            rejectProposal: makeRejectProposal()
        )
    }
    
    func makeApproveProposal() -> (String) -> Void {
        
        {
            [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.approve(id: id))
        }
    }
    
    func makeRejectProposal() -> (String) -> Void {
        
        {
            [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.reject(id: id))
        }
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
