// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
import UIKit
import web3walletcore

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

extension CultProposalsViewController {

    func update(with viewModel: CultProposalsViewModel) {
        self.viewModel = viewModel
        setTitleAsync()
        if viewModel is CultProposalsViewModel.Loading {
            showLoading()
        }
        if viewModel is CultProposalsViewModel.Error {
            hideLoading()
        }
        if viewModel is CultProposalsViewModel.Loaded {
            hideLoading()
            collectionView.reloadData()
            refreshControl.endRefreshing()
        }
    }

    func presentAlert(with viewModel: AlertViewModel) {
        let vc = AlertController(viewModel, handler: { _, _ in () })
        present(vc, animated: true)
    }

    func presentToast(with viewModel: ToastViewModel) {
        navigationController?.asNavVc?.toast(viewModel)
    }
}

extension CultProposalsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sectionList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.sectionList[section].itemList.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let section = viewModel.sectionList[indexPath.section]
        let item = section.itemList[indexPath.item]
        if section is CultProposalsViewModel.SectionPending {
            let cell = collectionView.dequeue(CultProposalCellPending.self, for: indexPath)
            return cell.update(with: item, handler: cultProposalCellPendingHandler(indexPath.item))
        }
        if section is CultProposalsViewModel.SectionClosed {
            let cell = collectionView.dequeue(CultProposalCellClosed.self, for: indexPath)
            return cell.update(with: item)
        }
        fatalError("Type not handled")
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
            let section = viewModel.sectionList[indexPath.section]
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
            let section = viewModel.sectionList[indexPath.section]
            footerView.update(with: section.footerItem)
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
        presenter.handleEvent(CultProposalsPresenterEvent.SelectProposal(idx: indexPath.row.int32))
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
    
    // NOTE: Annoyingly we need to do this since on iOS16 there is a glitch when setting a titleView directly on
    // viewDidLoad...hopefully we can remove this when fixed
    func setTitleAsync() {
        title = ""
        DispatchQueue.main.async { [weak self] in self?.setTitle() }
    }
    
    func setTitle() {
        if viewModel is CultProposalsViewModel.Loaded { setSegmentedTitle() }
        else { setDefaultTitle() }
    }
    
    func setDefaultTitle() {
        let cultIcon = UIImage(named: "degen-cult-icon")?
            .resize(to: .init(width: 32, height: 32))
        let imageView = UIImageView(image: cultIcon)
        let titleLabel = UILabel()
        titleLabel.text = Localized("cult.proposals.title")
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
        if
            let section = viewModel.sectionList.first,
            section is CultProposalsViewModel.SectionPending
        {
            segmentControl.selectedSegmentIndex = 0
        } else {
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
        if sender.selectedSegmentIndex == 0 {
            presenter.handleEvent(CultProposalsPresenterEvent.SelectPendingProposals())
        } else {
            presenter.handleEvent(CultProposalsPresenterEvent.SelectClosedProposals())
        }
    }
    
    func configureUI() {
        activityIndicator.color = Theme.color.textPrimary
        collectionView.setCollectionViewLayout(
            compositionalLayout(),
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
        refreshControl.tintColor = Theme.color.textPrimary
        refreshControl.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
//        navigationItem.searchController = searchController
//        searchController.searchResultsUpdater = self
    }
    
    @objc func didPullToRefresh(_ sender: Any) {
        presenter.present()
    }
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout(
            section: collectionLayoutSection()
        )
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
                view.frame.size.width - Theme.padding * 2
            ),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .padding
        section.interGroupSpacing = Theme.padding * 1.5
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

    func cultProposalCellPendingHandler(_ idx: Int) -> CultProposalCellPending.Handler {
        .init(
            approveProposal: approveProposal(idx: idx),
            rejectProposal: rejectProposal(idx: idx)
        )
    }
    
    func approveProposal(idx: Int) -> () -> Void {
        { [weak self] in self?.presenter.handleEvent(CultProposalsPresenterEvent.ApproveProposal(idx: idx.int32)) }
    }
    
    func rejectProposal(idx: Int) -> () -> Void {
        { [weak self] in self?.presenter.handleEvent(CultProposalsPresenterEvent.RejectProposal(idx: idx.int32)) }
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

private extension CultProposalsViewModel {
    var sectionList: [CultProposalsViewModel.Section] {
        guard let input = self as? CultProposalsViewModel.Loaded else {
            return []
        }
        return input.sections
    }
}

private extension CultProposalsViewModel.Section {
    var itemList: [CultProposalsViewModel.Item] {
        if let input = self as? CultProposalsViewModel.SectionPending {
            return input.items
        }
        if let input = self as? CultProposalsViewModel.SectionClosed {
            return input.items
        }
        return []
    }
    
    var footerItem: CultProposalsViewModel.Footer {
        if let input = self as? CultProposalsViewModel.SectionPending {
            return input.footer
        }
        if let input = self as? CultProposalsViewModel.SectionClosed {
            return input.footer
        }
        fatalError("Type not handled")
    }
}
