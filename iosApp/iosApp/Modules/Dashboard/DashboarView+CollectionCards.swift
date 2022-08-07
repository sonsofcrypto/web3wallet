// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension DashboardViewController {

    func configureCollectionCardsLayout() {
        collectionView.register(
            DashboardHeaderNameView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(DashboardHeaderNameView.self)"
        )
        collectionView.setCollectionViewLayout(
            compositionalLayout(),
            animated: false
        )
    }
}

private extension DashboardViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            guard self.viewModel != nil else { return nil }
            guard let section = self.viewModel?.sections[sectionIndex] else { return nil }
            
            switch section.items {
            case .actions:
                return self.buttonsCollectionLayoutSection()
            case .notifications:
                return self.notificationsCollectionLayoutSection()
            case .nfts:
                return self.makeNFTsCollectionLayoutSection()
            case .wallets:
                return self.walletsCollectionLayoutSection()
            }
        }
    }
    
    func buttonsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            .fractional(estimatedH: Theme.constant.buttonDashboardActionHeight),
            insets: .insets(h: 0)
        )
        let section = NSCollectionLayoutSection(
            group: .horizontal(.fractional(estimatedH: 100), items: [item]),
            insets: .padding
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(estimatedH: 50),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        section.orthogonalScrollingBehavior = .none
        return section
    }
    
    func notificationsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let width = floor((view.bounds.width - Theme.constant.padding * 3)  / 2)
        let group = NSCollectionLayoutGroup.horizontal(
            .estimated(view.bounds.width * 3, height: 64),
            items: [.init(layoutSize: .absolute(width, estimatedH: 64))]
        )
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        section.interGroupSpacing = Theme.constant.padding
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        return section
    }
    
    func walletsCollectionLayoutSection() -> NSCollectionLayoutSection {
        let width = floor((view.bounds.width - Theme.constant.padding * 3) / 2)
        let height = round(width * 0.95)
        let group = NSCollectionLayoutGroup.horizontal(
            .fractional(absoluteH: height),
            items: [.init(.absolute(width, height: height))]
        )
        group.interItemSpacing = .fixed(Theme.constant.padding)
        let section = NSCollectionLayoutSection(group: group, insets: .padding)
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .fractional(estimatedH: 100),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.interGroupSpacing = Theme.constant.padding
        section.boundarySupplementaryItems = [headerItem]
        return section
    }
    
    func makeNFTsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        let inset: CGFloat = Theme.constant.padding * 0.5
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalWidth(0.5)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: inset,
            leading: inset,
            bottom: inset,
            trailing: inset
        )
        
        // Group
        let screenWidth: CGFloat = (view.bounds.width - Theme.constant.padding)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(screenWidth),
            heightDimension: .absolute(screenWidth * 0.5)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let sectionInset: CGFloat = Theme.constant.padding * 0.5
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .init(
            top: sectionInset,
            leading: sectionInset,
            bottom: sectionInset + nftSectionBottomOffset,
            trailing: sectionInset
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
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                
        return section
    }
        
    var nftSectionBottomOffset: CGFloat {
        let sunsetImageWidth = view.frame.size.width - Theme.constant.padding * 2
        let sunsetImageHeight = sunsetImageWidth * 0.7
        return sunsetImageHeight - Theme.constant.padding * 4
    }

}
