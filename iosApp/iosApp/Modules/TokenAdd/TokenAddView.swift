// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenAddView: AnyObject {

    func update(with viewModel: TokenAddViewModel)
}

final class TokenAddViewController: BaseViewController {

    var presenter: TokenAddPresenter!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: TokenAddViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }    
}

extension TokenAddViewController: TokenAddView {

    func update(with viewModel: TokenAddViewModel) {

        self.viewModel = viewModel
        
        configureNavigationBar()

        if let visibleCell = collectionView.visibleCells.first as? TokenAddCollectionViewCell {
         
            visibleCell.update(
                with: viewModel,
                and: collectionView.frame.size.width
            )
            collectionView.collectionViewLayout.invalidateLayout()
        } else {
            collectionView.reloadData()
        }
    }
}

extension TokenAddViewController {
    
   func configureNavigationBar() {
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.textAlignment = .center
        titleLabel.text = viewModel?.title
        titleLabel.applyStyle(.navTitle)
        let vStack = VStackView([titleLabel])
        navigationItem.titleView = vStack

       navigationItem.leftBarButtonItem = UIBarButtonItem(
           imageName: "nav_bar_back",
           target: self,
           selector: #selector(navBarLeftActionTapped)
       )
       
       navigationItem.rightBarButtonItem = UIBarButtonItem(
           imageName: "nav_bar_scan",
           target: self,
           selector: #selector(addTokenTapped)
       )
    }
    
    func configureUI() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(resignFirstResponder))
        view.addGestureRecognizer(tapGesture)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraint = collectionView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor
        )
        constraint.priority = .required
        constraint.isActive = true
    }

    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
    
    @objc func addTokenTapped() {
        
        if let visibleCell = collectionView.visibleCells.first as? TokenAddCollectionViewCell {
            
            visibleCell.resignFirstResponder()
        }
        presenter.handle(.addToken)
    }
}

extension TokenAddViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let viewModel = viewModel else {
            fatalError()
        }
        
        let cell = collectionView.dequeue(
            TokenAddCollectionViewCell.self,
            for: indexPath
        )
        cell.update(
            with: viewModel,
            and: collectionView.frame.size.width
        )
        return cell
    }
}

extension TokenAddViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
                
        .init(width: collectionView.frame.width, height: 56)
    }
}
