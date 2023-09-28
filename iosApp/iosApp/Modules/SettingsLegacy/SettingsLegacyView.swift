// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SettingsLegacyViewController: BaseViewController {
    @IBOutlet weak var collectionView: CollectionView!

    var presenter: SettingsLegacyPresenter!

    private var viewModel: SettingsLegacyViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
}

extension SettingsLegacyViewController {

    @objc func dismissAction() {
        presenter.handle(.Dismiss())
    }
}

extension SettingsLegacyViewController {

    func update(with viewModel: SettingsLegacyViewModel) {
        self.viewModel = viewModel
        title = viewModel.title
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: "chevron.left".assetImage,
                style: .plain,
                target: self,
                action: #selector(dismissAction)
            )
        }
        collectionView.reloadData()
    }
}

extension SettingsLegacyViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.sections[section].items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let items = viewModel.sections[indexPath.section].items
        let item = items[indexPath.item]
        let cell = collectionView.dequeue(SettingsLegacyCell.self, for: indexPath)
        return cell.update(with: item, showSeparator: items.last != item)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = viewModel?.sections[indexPath.section].header else {
                fatalError("Unexpected header idxPath: \(indexPath) \(kind)")
            }
            return collectionView.dequeue(
                SettingsSectionHeaderViewCell.self,
                for: indexPath,
                kind: kind
            ).update(with: header, idx: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            guard let footer = viewModel?.sections[indexPath.section].footer else {
                fatalError("Unexpected footer idxPath: \(indexPath) \(kind)")
            }
            return collectionView.dequeue(
                SettingsSectionFooterViewCell.self,
                for: indexPath,
                kind: kind
            ).update(with: footer)
        default:
            fatalError("Unexpected idxPath: \(indexPath) \(kind)")
        }
    }
}

extension SettingsLegacyViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        presenter.handle(
            .Select(
                groupIdx: indexPath.section.int32,
                itemIdx: indexPath.item.int32
            )
        )
    }
}

private extension SettingsLegacyViewController{

    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            return self.makeItemCollectionLayoutSection(
                sectionIndex: sectionIndex,
                hasHeader: self.viewModel.sections[sectionIndex].header != nil,
                hasFooter: self.viewModel.sections[sectionIndex].footer != nil
            )
        }
        layout.register(
            DgenCellBackgroundSupplementaryView.self,
            forDecorationViewOfKind: "background"
        )
        return layout
    }
    
    func makeItemCollectionLayoutSection(
        sectionIndex: Int,
        hasHeader: Bool,
        hasFooter: Bool
    ) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(layoutSize: .fractional(estimatedH: 1))
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: .fractional(estimatedH: 1), subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = .padding(
            top: (hasHeader && sectionIndex == 0) ? Theme.padding * 2 - 12 : Theme.padding
        )
        if hasHeader {
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .fractional(estimatedH: 1),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems.append(headerItem)
        }
        if hasFooter {
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .fractional(estimatedH: 1),
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems.append(footerItem)
        }
        let backgroundItem = NSCollectionLayoutDecorationItem.background(
            elementKind: "background"
        )
        backgroundItem.contentInsets = .padding(
            top: hasHeader ? Theme.padding * (sectionIndex == 0 ? 3 : 2) : Theme.padding,
            bottom: hasFooter ? Theme.padding * 2 : Theme.padding
        )
        section.decorationItems = [backgroundItem]
        return section
    }
}

private extension SettingsLegacyViewController {
    
    func configureUI() {
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        collectionView.register(
            SettingsSectionHeaderViewCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: String(describing: SettingsSectionHeaderViewCell.self)
        )
        collectionView.register(
            SettingsSectionFooterViewCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: String(describing: SettingsSectionFooterViewCell.self)
        )
        collectionView.overscrollView = UIImageView(imgName: "overscroll_anon")
        let version = UILabel(with: .footnote)
        version.text = Bundle.main.version() + "v #" + Bundle.main.build()
        version.textAlignment = .center
        collectionView.overscrollView?.addSubview(version)
        version.sizeToFit()
        version.center = collectionView.overscrollView?.bounds.midXY ?? .zero
        version.center.x -= 1.5
        version.center.y += 31
    }
}
