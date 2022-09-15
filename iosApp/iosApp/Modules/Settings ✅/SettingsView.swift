// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsView: AnyObject {
    func update(with viewModel: SettingsViewModel)
}

final class SettingsViewController: BaseViewController {

    var presenter: SettingsPresenter!

    @IBOutlet weak var collectionView: CollectionView!

    private var viewModel: SettingsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }
}

extension SettingsViewController {

    @objc func dismissAction() {
        presenter.handle(.dismiss)
    }
}

extension SettingsViewController: SettingsView {

    func update(with viewModel: SettingsViewModel) {
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

extension SettingsViewController: UICollectionViewDataSource {
    
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
        case .footer:
            return 1
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = viewModel?.sections[indexPath.section] else { fatalError() }
        switch section {
        case let .header(header):
            let cell = collectionView.dequeue(SettingsSectionHeaderViewCell.self, for: indexPath)
            cell.update(with: header)
            return cell
        case let .group(items):
            let item = items[indexPath.item]
            let cell = collectionView.dequeue(SettingsCell.self, for: indexPath)
            return cell.update(with: item, showSeparator: items.last != item)
        case let .footer(footer):
            let cell = collectionView.dequeue(SettingsSectionFooterViewCell.self, for: indexPath)
            cell.update(with: footer)
            return cell
        }
    }
}

extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let item = viewModel.item(at: indexPath)
        presenter.handle(.didSelect(setting: item.setting))
    }
}

private extension SettingsViewController{

    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }
            guard let viewModel = self.viewModel else { return nil }
            switch viewModel.sections[sectionIndex] {
            case .header:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: false,
                    isHeader: true,
                    sectionIndex: sectionIndex
                )
            case .group:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: true,
                    isHeader: false,
                    sectionIndex: sectionIndex
                )
            case .footer:
                return self.makeCollectionLayoutSection(
                    withBackgroundDecoratorView: false,
                    isHeader: true,
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
        isHeader: Bool,
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
        section.contentInsets = isHeader ?
            .init(
                top: sectionIndex == 0 ? Theme.constant.padding : 0,
                leading: Theme.constant.padding,
                bottom: 0,
                trailing: Theme.constant.padding
            ) : .padding
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        let footerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let footerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerItemSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        section.boundarySupplementaryItems = [headerItem, footerItem]
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

private extension SettingsViewController {
    
    func configureUI() {
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        collectionView.overScrollView.image = "overscroll_anon".assetImage
        let version = UILabel(with: .footnote)
        version.text = Bundle.main.version() + "v #" + Bundle.main.build()
        version.textAlignment = .center
        collectionView.overScrollView.addSubview(version)
        version.sizeToFit()
        version.center = collectionView.overScrollView.bounds.midXY
        version.center.x -= 1.5
        version.center.y += 31
    }
}
