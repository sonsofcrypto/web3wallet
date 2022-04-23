// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol DegenView: AnyObject {

    func update(with viewModel: DegenViewModel)
}

class DegenViewController: BaseViewController {

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

// MARK: - DegenView

extension DegenViewController: DegenView {

    func update(with viewModel: DegenViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension DegenViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  viewModel?.items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(DegenCell.self, for: indexPath)
        cell.update(with: viewModel?.items[indexPath.row])
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
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

// MARK: - UICollectionViewDelegateFlowLayout

extension DegenViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: Constant.cellHeight
        )
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: Constant.headerHeight
        )
    }
}

extension DegenViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectCategory(idx: indexPath.item))
    }
}

// MARK: - Configure UI

extension DegenViewController {
    
    func configureUI() {
        navigationItem.backButtonTitle = ""

        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]

        var insets = collectionView.contentInset
        insets.bottom += Global.padding
        collectionView.contentInset = insets

        let overScrollView = (collectionView as? CollectionView)
        overScrollView?.overScrollView.image = UIImage(named: "overscroll_degen")
        overScrollView?.overScrollView.layer.transform = CATransform3DMakeTranslation(0, -100, 0)
        navigationItem.backButtonTitle = ""
    }

    func configureNavAndTabBarItem() {
        title = Localized("degen")
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "tab_icon_degen"),
            tag: 1
        )
    }
}

// MARK: - Constant

private extension DegenViewController {

    enum Constant {
        static let cellHeight: CGFloat = 78
        static let headerHeight: CGFloat = 86
    }

}
