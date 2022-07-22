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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeue(DegenCell.self, for: indexPath)
        cell.update(with: viewModel?.items[indexPath.row])
        return cell
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let supplementary = collectionView.dequeue(
                DegenSectionTitleView.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: viewModel)
            return supplementary
        }

        fatalError("Unexpected supplementary \(kind) \(indexPath)")
    }
}

//extension DegenViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(
//            width: view.bounds.width - Theme.constant.padding * 2,
//            height: Constant.cellHeight
//        )
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(
//            width: view.bounds.width - Theme.constant.padding * 2,
//            height: Constant.headerHeight
//        )
//    }
//}

extension DegenViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectCategory(idx: indexPath.item))
    }
}

extension DegenViewController {
    
    func configureUI() {
        
//        navigationItem.backButtonTitle = ""
//
//        var insets = collectionView.contentInset
//        insets.bottom += Theme.constant.padding
//        collectionView.contentInset = insets
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )

        let overScrollView = (collectionView as? CollectionView)
        overScrollView?.overScrollView.image = UIImage(named: "overscroll_degen")
        overScrollView?.overScrollView.layer.transform = CATransform3DMakeTranslation(0, -100, 0)
        navigationItem.backButtonTitle = ""
    }

    func configureNavAndTabBarItem() {
        title = Localized("degen")
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout(
            section: makeCollectionLayoutSection()
        )
    }
    
    func makeCollectionLayoutSection() -> NSCollectionLayoutSection {
        
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
        section.contentInsets = .paddingDefault
        section.interGroupSpacing = Theme.constant.padding
        
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
        
        return section
    }
}
