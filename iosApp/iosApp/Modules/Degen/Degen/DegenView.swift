// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenView: AnyObject {

    func update(with viewModel: DegenViewModel)
}

final class DegenViewController: BaseViewController {

    var presenter: DegenPresenter!

    private var viewModel: DegenViewModel?

    @IBOutlet weak var collectionView: UICollectionView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavAndTabBarItem()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureNavAndTabBarItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }
    }
}

extension DegenViewController: DegenView {

    func update(with viewModel: DegenViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

extension DegenViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        viewModel?.sections.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        guard let section = viewModel?.sections[section] else {
            
            return 0
        }
        
        switch section {
        case .header:
            return 1
        case let .group(items):
            return items.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let section = viewModel?.sections[indexPath.section] else { fatalError() }
        
        switch section {
            
        case let .header(header):
            let cell = collectionView.dequeue(DegenSectionViewCell.self, for: indexPath)
            cell.update(with: header)
            return cell
            
        case let .group(items):
            let item = items[indexPath.item]
            let cell = collectionView.dequeue(DegenViewCell.self, for: indexPath)
            cell.update(with: item, showSeparator: items.last != item)
            return cell
        }
    }
}

extension DegenViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {

        guard let section = viewModel?.sections[indexPath.section] else { return }
        
        guard case let DegenViewModel.Section.group(items) = section else { return }
        
        if items[indexPath.row].isEnabled {
            presenter.handle(.didSelectCategory(idx: indexPath.item))
        } else {
            presenter.handle(.comingSoon)
        }
    }
}

extension DegenViewController {
    
    func configureUI() {
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )

        let overScrollView = (collectionView as? CollectionView)
        overScrollView?.overScrollView.image = "overscroll_degen".assetImage
        overScrollView?.overScrollView.layer.transform = CATransform3DMakeTranslation(0, -100, 0)
        navigationItem.backButtonTitle = ""
    }

    func configureNavAndTabBarItem() {
        title = Localized("degen")
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            
            guard let self = self else { return nil }
            
            guard let viewModel = self.viewModel else { return nil }
            
            switch viewModel.sections[sectionIndex] {
                
            case .header:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: false,
                    sectionIndex: sectionIndex
                )

            case .group:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: true,
                    sectionIndex: sectionIndex
                )
            }
        }
        layout.register(
            DgenCellBackgroundSupplementaryView.self,
            forDecorationViewOfKind: "background"
        )
        return layout
    }
  
    func makeCollectionLayoutSection(
        withBackgroundDecoratorView addBackgroundDecorator: Bool,
        sectionIndex: Int
    ) -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        //item.contentInsets = .paddingHalf
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        //outerGroup.contentInsets = .paddingHalf
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = sectionIndex.isMultiple(of: 2) ?
            .init(
                top: sectionIndex == 0 ? Theme.constant.padding : 0,
                leading: Theme.constant.padding,
                bottom: 0,
                trailing: Theme.constant.padding
            ) :
            .init(
                top: Theme.constant.padding,
                leading: Theme.constant.padding,
                bottom: sectionIndex == 0 ? 0 : Theme.constant.padding,
                trailing: Theme.constant.padding
            )
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]
        
        if addBackgroundDecorator {

            let backgroundItem = NSCollectionLayoutDecorationItem.background(
                elementKind: "background"
            )
            backgroundItem.contentInsets = .paddingDefault
            section.decorationItems = [backgroundItem]
        }
        
        return section
    }
}
