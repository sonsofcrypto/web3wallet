// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksView: AnyObject {
    
    func update(with viewModel: NetworksViewModel)
}

final class NetworksViewController: BaseViewController {
    
    var presenter: NetworksPresenter!
    
    private var viewModel: NetworksViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        viewModel.network().count ?? 0
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeue(NetworksCell.self, for: indexPath)
        cell.update(
            with: viewModel.network()[indexPath.item],
            handler: makeNetworksCellHandler()
        )
        return cell
    }
}

extension NetworksViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let viewModel = viewModel.network()[indexPath.item]
        
        guard viewModel.connected != nil else { return }
        
        presenter.handle(.didSelectNetwork(networkId: viewModel.networkId))
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let viewModel = viewModel, case let NetworksViewModel.loaded(header, _) = viewModel else {
            
            fatalError("We should always have networks")
        }
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let supplementary = collectionView.dequeue(
                NetworkHeaderCell.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: header)
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
            top: inset * 0.5,
            leading: inset,
            bottom: inset * 0.5,
            trailing: inset
        )
        
        // Group
        let screenWidth: CGFloat = (view.bounds.width - Theme.constant.padding * 1.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .absolute(156)
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
    
    func makeNetworksCellHandler() -> NetworksCell.Handler {
        
        .init(
            onNetworkSwitch: makeOnNetworkSwitch(),
            onSettingsTapped: makeOnSettingsTapped()
        )
    }
    
    func makeOnNetworkSwitch() -> (String, Bool) -> Void {
        
        {
            [weak self] (networkId, isOn) in
            guard let self = self else { return }
            self.presenter.handle(.didSwitchNetwork(networkId: networkId, isOn: isOn))
        }
    }
    
    func makeOnSettingsTapped() -> (String) -> Void {

        {
            [weak self] networkId in
            guard let self = self else { return }
            self.presenter.handle(.didTapSettings(networkId))
        }

    }
}
