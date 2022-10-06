// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class ImprovementProposalsViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var segmentCtl: SegmentedControl!

    var presenter: ImprovementProposalsPresenter!

    private var viewModel: ImprovementProposalsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (navigationController as? NavigationController)?.contentView = segmentCtl
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (navigationController as? NavigationController)?.contentView = nil
    }
}

extension ImprovementProposalsViewController: ImprovementProposalsView {

    func update(viewModel: ImprovementProposalsViewModel) {
        self.viewModel = viewModel
        if let loading = viewModel as? ImprovementProposalsViewModel.Loading {
            collectionView.refreshControl?.beginRefreshing()
        }
        if let error = viewModel as? ImprovementProposalsViewModel.Error {
            collectionView.refreshControl?.endRefreshing()
            let alert = UIAlertController(
                error.error,
                handlers: [{ [weak self] action in self?.handle(action) }]
            )
            present(alert, animated: true)
        }
        if let loaded = viewModel as? ImprovementProposalsViewModel.Loaded {
            collectionView.refreshControl?.endRefreshing()
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

    @IBAction func segmentCtlAction(_ sender: SegmentedControl) {
        presenter.handle(
            event____: .Category(idx: Int32(sender.selectedSegmentIndex))
        )
    }

    @objc func refreshAction(_ sender: Any) {
        presenter.present()
    }

    @IBAction func dismissAction() {
        presenter.handle(event____: .Dismiss())
    }

    func handle(_ alertAction: UIAlertAction) {
        presenter.handle(event____: .AlertAction(idx: 0))
    }
}

private extension ImprovementProposalsViewController {

    func configureUI() {
        collectionView.setCollectionViewLayout(layout(), animated: false)
        collectionView.backgroundView = ThemeGradientView()
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addValueChangedTarget(
            self,
            action: #selector(refreshAction(_:))
        )
    }

    func layout() -> UICollectionViewCompositionalLayout {
        let item = NSCollectionLayoutItem(.fractional(1, estimatedH: 1))
        let groupSize = NSCollectionLayoutSize.absolute(
            view.frame.size.width - Theme.constant.padding * 2,
            estimatedH: 100
        )
        let group = NSCollectionLayoutGroup.horizontal(groupSize, items: [item])
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        section.interGroupSpacing = Theme.constant.padding
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(1, estimatedH: 100),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        return UICollectionViewCompositionalLayout(section: section)
    }
}
