// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DegenViewController: BaseViewController {
    @IBOutlet weak var collectionView: CollectionView!

    var presenter: DegenPresenter!

    private var viewModel: DegenViewModel?

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

    deinit {
        presenter.releaseResources()
    }
}

extension DegenViewController {

    func update(with viewModel: DegenViewModel) {
        self.viewModel = viewModel
        collectionView?.reloadData()
    }
    
    func popToRootAndRefresh() {
        navigationController?.popToRootViewController(animated: false)
        presenter.present()
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
        guard let section = viewModel?.sections[section] else { return 0 }
        if section is DegenViewModel.SectionHeader { return 1 }
        if let input = section as? DegenViewModel.SectionGroup {
            return input.items.count
        }
        fatalError("Section type not handled")
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = viewModel?.sections[indexPath.section] else { fatalError() }
        if let input = section as? DegenViewModel.SectionHeader {
            let cell = collectionView.dequeue(DegenSectionViewCell.self, for: indexPath)
            cell.update(with: input)
            return cell
        }
        if let input = section as? DegenViewModel.SectionGroup {
            let item = input.items[indexPath.item]
            let cell = collectionView.dequeue(DegenViewCell.self, for: indexPath)
            cell.update(with: item, showSeparator: input.items.last != item)
            return cell
        }
        fatalError("Section type not handled")
    }
}

extension DegenViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let section = viewModel?.sections[indexPath.section] else { return }
        if let input = section as? DegenViewModel.SectionGroup {
            if input.items[indexPath.row].isEnabled {
                presenter.handle(.DidSelectCategory(idx: indexPath.item.int32))
            } else {
                presenter.handle(DegenPresenterEvent.ComingSoon())
            }
        }
    }
}

extension DegenViewController {
    
    func configureUI() {
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        collectionView.overscrollView = UIImageView(imgName: "overscroll_degen")
    }

    func configureNavAndTabBarItem() {
        title = Localized("degen")
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            guard let viewModel = self.viewModel else { return nil }
            if viewModel.sections[sectionIndex] is DegenViewModel.SectionHeader {
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: false,
                    sectionIndex: sectionIndex
                )
            }
            if viewModel.sections[sectionIndex] is DegenViewModel.SectionGroup {
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: true,
                    sectionIndex: sectionIndex
                )
            }
            fatalError("Section type not handled")
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
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = sectionIndex.isMultiple(of: 2) ?
            .init(
                top: sectionIndex == 0 ? Theme.padding : 0,
                leading: Theme.padding,
                bottom: 0,
                trailing: Theme.padding
            ) :
            .init(
                top: Theme.padding,
                leading: Theme.padding,
                bottom: sectionIndex == 0 ? 0 : Theme.padding,
                trailing: Theme.padding
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
            backgroundItem.contentInsets = .padding
            section.decorationItems = [backgroundItem]
        }
        return section
    }
}
