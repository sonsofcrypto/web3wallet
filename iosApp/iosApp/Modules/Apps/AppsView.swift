// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AppsView: AnyObject {

    func update(with viewModel: AppsViewModel)
}

final class AppsViewController: BaseViewController {

    var presenter: AppsPresenter!

    private var viewModel: AppsViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override init(
        nibName nibNameOrNil: String?,
        bundle nibBundleOrNil: Bundle?
    ) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension AppsViewController: AppsView {

    func update(with viewModel: AppsViewModel) {

        self.viewModel = viewModel
        
        collectionView.reloadData()
        
//        if let idx = viewModel.selectedIdx(), !viewModel.items().isEmpty {
//            for i in 0..<viewModel.items().count {
//                collectionView.selectItem(
//                    at: IndexPath(item: i, section: 0),
//                    animated: idx == i,
//                    scrollPosition: .top
//                )
//            }
//        }
    }
}

extension AppsViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        viewModel?.items().count ?? 0
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let viewModel = viewModel?.items()[indexPath.item]
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeue(
                AppsHeaderCollectionViewCell.self,
                for: indexPath
            )
            cell.update(
                with: viewModel,
                width: collectionView.frame.size.width
            )
            return cell
        } else {
            let cell = collectionView.dequeue(
                AppsCollectionViewCell.self,
                for: indexPath
            )
            cell.update(with: viewModel)
            return cell
        }
    }
}

extension AppsViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let index = indexPath.row - 1
        guard index >= 0 else { return }
        presenter.handle(.itemSelectedAt(index: index))
    }
}

extension AppsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        .init(
            width: collectionView.frame.width,
            height: Global.cellHeight
        )
    }
}

private extension AppsViewController {
    
    func configureUI() {
        
        title = Localized("apps")

        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
    }
}
