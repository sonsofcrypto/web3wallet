// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsView: AnyObject {
    func update(with viewModel: CultProposalsViewModel)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
final class CultProposalsViewController: BaseViewController {
    
    //let searchController = UISearchController()
========
final class FeaturesViewController: BaseViewController {
    //let searchController = UISearchController()
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var segmentContainer: UIView!
>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
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

<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
    func update(with viewModel: CultProposalsViewModel) {
        self.viewModel = viewModel
        setTitle()
========
    func update(with viewModel: FeaturesViewModel) {
        self.viewModel = viewModel
        title = viewModel.title

>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
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
<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
        switch section.type {
        case .pending:
            let cell = collectionView.dequeue(CultProposalCellPending.self, for: indexPath)
            return cell.update(with: viewModel, handler: makeCultProposalCellPendingHandler())
        case .closed:
            let cell = collectionView.dequeue(CultProposalCellClosed.self, for: indexPath)
            return cell.update(with: viewModel)
        }
========
        let cell = collectionView.dequeue(FeaturesCell.self, for: indexPath)
        let idx = indexPath.item
        return cell.update(
            with: viewModel,
            handler: { [weak self] in self?.presenter.handle(.vote(idx: idx)) }
        )
>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
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
<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
        let section = viewModel.sections[indexPath.section]
        let item = section.items[indexPath.row]
        presenter.handle(.selectProposal(id: item.id))
========
        presenter.handle(.select(idx: indexPath.item))
>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
    }

//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
    func setTitle() {
        switch viewModel {
        case .loading, .error, .none:
            setDefaultTitle()
        case .loaded:
            setSegmentedTitle()
        }
    }
    
    func setDefaultTitle() {
        let cultIcon = viewModel.titleIconName.assetImage?.resize(to: .init(width: 32, height: 32))
        let imageView = UIImageView(image: cultIcon)
        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.apply(style: .navTitle)
        let stackView = HStackView([imageView, titleLabel])
        stackView.spacing = 4
        navigationItem.titleView = stackView
    }
    
    func setSegmentedTitle() {
========
    func setSegmented() {
>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
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
<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
        presenter.handle(
            .filterBySection(
                sectionType: sender.selectedSegmentIndex == 0 ? .pending : .closed
            )
        )
========
        presenter.handle(.didSelectCategory(idx: sender.selectedSegmentIndex))
>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
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
        section.contentInsets = .padding
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

<<<<<<<< HEAD:iosApp/iosApp/Modules/DegenCult ✅/CultProposals ✅/CultProposalsView.swift
private extension CultProposalsViewController {

    func makeCultProposalCellPendingHandler() -> CultProposalCellPending.Handler {
        .init(
            approveProposal: makeApproveProposal(),
            rejectProposal: makeRejectProposal()
        )
    }
    
    func makeApproveProposal() -> (String) -> Void {
        { [weak self] id in self?.presenter.handle(.approveProposal(id: id)) }
    }
    
    func makeRejectProposal() -> (String) -> Void {
        { [weak self] id in self?.presenter.handle(.rejectProposal(id: id)) }
    }
}

//extension CultProposalsViewController: UISearchResultsUpdating {
//    
========
//extension FeaturesViewController: UISearchResultsUpdating {
//
>>>>>>>> develop:iosApp/iosApp/Modules/Proposals/FeaturesView.swift
//    func updateSearchResults(for searchController: UISearchController) {
//        
//        guard let text = searchController.searchBar.text else { return }
//        
//        presenter.handle(.filterBy(text: text))
//    }
//}
