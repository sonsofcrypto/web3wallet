// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsView: AnyObject {

    func update(with viewModel: CultProposalsViewModel)
}

final class CultProposalsViewController: BaseViewController {
    
    //let searchController = UISearchController()
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    private let refreshControl = UIRefreshControl()

    var presenter: CultProposalsPresenter!

    private var viewModel: CultProposalsViewModel!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension CultProposalsViewController: CultProposalsView {

    func update(with viewModel: CultProposalsViewModel) {
        
        self.viewModel = viewModel
                
        setTitle()

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

extension CultProposalsViewController: UICollectionViewDataSource {
    
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
        
        switch section.type {
        case .pending:
            let cell = collectionView.dequeue(CultProposalCellPending.self, for: indexPath)
            return cell.update(with: viewModel, handler: makeCultProposalCellPendingHandler())
        case .closed:
            let cell = collectionView.dequeue(CultProposalCellClosed.self, for: indexPath)
            return cell.update(with: viewModel)
        }
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
                withReuseIdentifier: String(describing: CultProposalHeaderSupplementaryView.self),
                for: indexPath
            ) as? CultProposalHeaderSupplementaryView else {
                
                return CultProposalHeaderSupplementaryView()
            }
            
            let section = viewModel.sections[indexPath.section]
            headerView.update(with: section)
            return headerView
            
        case "footer":
            
            guard let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: CultProposalFooterSupplementaryView.self),
                for: indexPath
            ) as? CultProposalFooterSupplementaryView else {
                
                return CultProposalFooterSupplementaryView()
            }
            
            let section = viewModel.sections[indexPath.section]
            footerView.update(with: section.footer)
            return footerView
            
        default:
            assertionFailure("Unexpected element kind: \(kind).")
            return UICollectionReusableView()
        }
    }
}

extension CultProposalsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        let section = viewModel.sections[indexPath.section]
        let item = section.items[indexPath.row]
        presenter.handle(.selectProposal(id: item.id))
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        searchController.searchBar.resignFirstResponder()
//    }
}

private extension CultProposalsViewController {
    
    func showLoading() {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func setTitle() {
        
        switch viewModel {
            
        case .loading, .error, .none:
            
            setDefaultTitle()

        case .loaded:
            
            setSegmentedTitle()
        }
    }
    
    func setDefaultTitle() {
        
        let cultIcon = viewModel.titleIcon.pngImage!.resize(to: .init(width: 32, height: 32))
        let imageView = UIImageView(image: cultIcon)
        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.apply(style: .navTitle)
        
        let stackView = HStackView([imageView, titleLabel])
        stackView.spacing = 4
        
        navigationItem.titleView = stackView
    }
    
    func setSegmentedTitle() {
        
        let segmentControl = SegmentedControl()
        segmentControl.insertSegment(
            withTitle: Localized("cult.proposals.segmentedControl.pending"),
            at: 0,
            animated: false
        )
        segmentControl.insertSegment(
            withTitle: Localized("cult.proposals.segmentedControl.closed"),
            at: 1,
            animated: false
        )
        
        switch viewModel.selectedSectionType {
            
        case .pending:
            segmentControl.selectedSegmentIndex = 0
        case .closed:
            segmentControl.selectedSegmentIndex = 1
        }
        
        segmentControl.addTarget(
            self,
            action: #selector(segmentControlChanged(_:)),
            for: .valueChanged
        )
        navigationItem.titleView = segmentControl
    }
    
    @objc func segmentControlChanged(_ sender: SegmentedControl) {
        
        presenter.handle(
            .filterBySection(
                sectionType: sender.selectedSegmentIndex == 0 ? .pending : .closed
            )
        )
    }
    
    func configureUI() {
        
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
        section.contentInsets = .paddingDefault
        section.interGroupSpacing = Theme.constant.padding * 1.5
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: "header",
            alignment: .top
        )
        let footerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerItemSize,
            elementKind: "footer",
            alignment: .bottom
        )
        
        section.boundarySupplementaryItems = [headerItem, footerItem]
        
        return section
    }
}

private extension CultProposalsViewController {

    func makeCultProposalCellPendingHandler() -> CultProposalCellPending.Handler {
        
        .init(
            approveProposal: makeApproveProposal(),
            rejectProposal: makeRejectProposal()
        )
    }
    
    func makeApproveProposal() -> (String) -> Void {
        
        {
            [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.approveProposal(id: id))
        }
    }
    
    func makeRejectProposal() -> (String) -> Void {
        
        {
            [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.rejectProposal(id: id))
        }
    }

}

//extension CultProposalsViewController: UISearchResultsUpdating {
//    
//    func updateSearchResults(for searchController: UISearchController) {
//        
//        guard let text = searchController.searchBar.text else { return }
//        
//        presenter.handle(.filterBy(text: text))
//    }
//}
