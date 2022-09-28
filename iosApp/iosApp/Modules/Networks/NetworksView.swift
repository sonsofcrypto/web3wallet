// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksView: AnyObject {
    
    func update(with viewModel: NetworksViewModel)
}

final class NetworksViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var presenter: NetworksPresenter!

    private var viewModel: NetworksViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension NetworksViewController: NetworksView {
    
    func update(with viewModel: NetworksViewModel) {
        if self.viewModel?.count() != viewModel.count() {
            self.viewModel = viewModel
            collectionView.reloadData()
            collectionView.deselectAllExcept(viewModel.selectedIndexPaths())
            return
        }

        self.viewModel = viewModel
        collectionView.deselectAllExcept(viewModel.selectedIndexPaths())
        collectionView.visibleCells.forEach {
            let idxPath = collectionView.indexPath(for: $0)
            update(cell: $0 as? NetworksCell, with: networkViewModel(idxPath))
        }
    }
}

// MARK: - UICollectionViewDataSource

extension NetworksViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.sections[section].networks.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeue(NetworksCell.self, for: indexPath)
        update(cell: cell, with: networkViewModel(indexPath))
        return cell
    }

    func update(cell: NetworksCell?, with viewModel: NetworksViewModel.Network?) {
        cell?.update(
            with: viewModel,
            handler: makeNetworkCellHandler()
        )
    }
}

// MARK: - UICollectionViewDelegate

extension NetworksViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if let viewModel = networkViewModel(indexPath) {
            presenter.handle(.didSelectNetwork(chainId: viewModel.chainId))
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard let viewModel = viewModel else {
            fatalError("We should always have networks")
        }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let supplementary = collectionView.dequeue(
                NetworksSectionHeaderView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.label.text = viewModel.sections[indexPath.section].header
            return supplementary
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }
}

// MARK: - Configure

private extension NetworksViewController {
    
    func configureUI() {
        title = Localized("networks")
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
    }
    
    func makeCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(130)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(130)
            ),
            subitems: [NSCollectionLayoutItem(layoutSize: itemSize)]
        )
        let section = NSCollectionLayoutSection(
            group: group,
            insets: .init(
                top: Theme.constant.padding,
                leading: Theme.constant.padding,
                bottom: 0,
                trailing: Theme.constant.padding
            )
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top,
            leading: Theme.constant.padding / 4.0,
            trailing: -Theme.constant.padding * 2
        )
        section.boundarySupplementaryItems = [headerItem]
        section.interGroupSpacing = Theme.constant.padding
        return UICollectionViewCompositionalLayout(section: section)
    }

    func networkViewModel(_ idxPath: IndexPath?) -> NetworksViewModel.Network? {
        guard let idxPath = idxPath else {
            return nil
        }
        return viewModel?
            .sections[safe: idxPath.section]?
            .networks[safe: idxPath.item]
    }
}

private extension NetworksViewController {
    
    func makeNetworkCellHandler() -> NetworksCell.Handler {
        .init(
            onOffHandler: { [weak self] (id, on) in
                self?.handleNetworkToggle(id, on)
            },
            settingsHandler: { [weak self] id in
                self?.handleSettingsAction(id)
            }
        )
    }

    func handleNetworkToggle(_ chainId: UInt32, _ isOn: Bool) {
        presenter.handle(.didSwitchNetwork(chainId: chainId, isOn: isOn))
    }

    func handleSettingsAction(_ chainId: UInt32) {
        presenter.handle(.didTapSettings(chainId: chainId))
    }
}
