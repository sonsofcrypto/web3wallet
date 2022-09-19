// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - TokenAddView

protocol TokenAddView: AnyObject {
    func update(with viewModel: TokenAddViewModel)
    func dismissKeyboard()
}

// MARK: - TokenAddViewController

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
                handler: tokenAddCollectionViewCellHandler(),
                and: collectionView.frame.size.width
            )
            collectionView.collectionViewLayout.invalidateLayout()
        } else {
            collectionView.reloadData()
        }
    }
    
    func dismissKeyboard() {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

// MARK: - Configure

extension TokenAddViewController {
    
   func configureNavigationBar() {
       title = viewModel?.title

       navigationItem.leftBarButtonItem = UIBarButtonItem(
        image: "chevron.left".assetImage,
           style: .plain,
           target: self,
           action: #selector(navBarLeftActionTapped)
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
}

// MARK: - UICollectionViewDataSource

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
            handler: tokenAddCollectionViewCellHandler(),
            and: collectionView.frame.size.width
        )
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TokenAddViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(width: collectionView.frame.width, height: 56)
    }
}

// MARK: - Handlers

private extension TokenAddViewController {
    
    func tokenAddCollectionViewCellHandler() -> TokenAddCollectionViewCell.Handler {
        .init(
            selectNetworkHandler: presenterHandle(.selectNetwork),
            addressHandler: addressHandler(),
            addTokenHandler: presenterHandle(.addToken),
            onTextChanged: onTextChanged(),
            onReturnTapped: onReturnTapped()
        )
    }
    
    func addressHandler() -> TokenEnterAddressView.Handler {
        .init(
            onAddressChanged: onAddressChanged(),
            onQRCodeScanTapped: presenterHandle(.qrCodeScan),
            onPasteTapped: presenterHandle(.pasteAddress),
            onSaveTapped: {}
        )
    }
    
    func onAddressChanged() -> (String) -> Void {
        {
            [weak self] value in
            self?.presenterHandle(.addressChanged(to: value))()
        }
    }
    
    func presenterHandle(_ event: TokenAddPresenterEvent) -> () -> Void {
        {
            [weak self] in self?.presenter.handle(event)
        }
    }
    
    func onTextChanged() -> (TokenAddViewModel.TextFieldType, String) -> Void {
        {
            [weak self] (type, value) in
            self?.presenterHandle(.inputChanged(for: type, to: value))()
        }
    }
    
    func onReturnTapped() -> (TokenAddViewModel.TextFieldType) -> Void {
        {
            [weak self] type in
            self?.presenterHandle(.returnKeyTapped(for: type))()
        }
    }
}
