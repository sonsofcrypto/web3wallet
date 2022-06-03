// Created by web3d4v on 02/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ChatView: AnyObject {

    func update(with viewModel: ChatViewModel)
}

final class ChatViewController: BaseViewController {

    var presenter: ChatPresenter!

    private var viewModel: ChatViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureNavAndTabBarItem()
        configureUI()
        presenter?.present()
    }
}

extension ChatViewController: ChatView {

    func update(with viewModel: ChatViewModel) {

        self.viewModel = viewModel
        
        collectionView.reloadData()
    }
}

extension ChatViewController {
    
    func configureUI() {
        
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
    }

    func configureNavAndTabBarItem() {
        
        title = Localized("chat")
    }
}

extension ChatViewController: UICollectionViewDataSource {
    
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
        
        let cell = collectionView.dequeue(
            ChatCollectionViewCell.self,
            for: indexPath
        )
        cell.update(with: viewModel)
        return cell
    }
}

extension ChatViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {

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
