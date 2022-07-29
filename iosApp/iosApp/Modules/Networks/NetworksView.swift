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

    private var viewModel: NetworksViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

extension NetworksViewController: NetworksView {
    
    func update(with viewModel: NetworksViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

extension NetworksViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel.sections.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.sections[section].networks.count
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeue(NetworksCell.self, for: indexPath)
        cell.update(
            with: viewModel.sections[indexPath.section].networks[indexPath.item],
            onNetworkSwitch: { [weak self] (id, on) in
                self?.handleNetworkToggle(id, on)
            },
            onSettingsTapped: { [weak self] id in
                self?.handleSettingsAction(id)
            }
        )
        return cell
    }
}

extension NetworksViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let idxPath = indexPath
        let viewModel = viewModel.sections[idxPath.section].networks[idxPath.item]
        presenter.handle(.didSelectNetwork(chainId: viewModel.chainId))
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
                NetworkHeaderCell.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: viewModel.sections[indexPath.section].header)
            return supplementary
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }
}

private extension NetworksViewController {
    
    func configureUI() {
        
        title = Localized("networks")
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        
        collectionView.register(
            NetworkHeaderCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(NetworkHeaderCell.self)"
        )
    }
    
    func makeCompositionalLayout() -> UICollectionViewLayout {
        
        let inset: CGFloat = Theme.constant.padding
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: inset,
            leading: inset,
            bottom: inset,
            trailing: inset
        )
        
        // Group
        let screenWidth: CGFloat = (view.bounds.width - Theme.constant.padding * 1.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: inset,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

private extension NetworksViewController {

    func handleNetworkToggle(_ chainId: UInt32, _ isOn: Bool) {
        presenter.handle(.didSwitchNetwork(chainId: chainId, isOn: isOn))
    }

    func handleSettingsAction(_ chainId: UInt32) {
        presenter.handle(.didTapSettings(chainId: chainId))
    }
}
