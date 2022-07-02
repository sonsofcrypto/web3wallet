// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenPickerView: AnyObject {

    func update(with viewModel: TokenPickerViewModel)
}

final class TokenPickerViewController: BaseViewController {
    
    enum CollectionTag: Int {
        
        case filters = 1
        case items = 2
    }

    var presenter: TokenPickerPresenter!

    private var viewModel: TokenPickerViewModel?
    
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var searchContainerBox: UIView!
    @IBOutlet weak var searchTextFieldBox: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var clearSearchButton: UIButton!
    
    private var searchTerm = ""

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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

extension TokenPickerViewController {
    
    @IBAction func clearSearchInputText() {
        
        searchTextField.text = ""
        presenter.handle(.search(searchTerm: ""))
    }
}

extension TokenPickerViewController: TokenPickerView {

    func update(with viewModel: TokenPickerViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title
        
        clearSearchButton.isHidden = searchTextField.text?.isEmpty ?? true
        
        filtersCollectionView.reloadData()
        itemsCollectionView.reloadData()
                
        if viewModel.allowMultiSelection {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "plus"),
                style: .plain,
                target: self,
                action: #selector(addCustomToken)
            )
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: Localized("done"),
                style: .plain,
                target: self,
                action: #selector(doneTapped)
            )
            itemsCollectionView.allowsMultipleSelection = viewModel.allowMultiSelection
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: Localized("close"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
        }
    }
}

private extension TokenPickerViewController {
    
    func configureUI() {
        
        searchContainerBox.backgroundColor = Theme.colour.navBarBackground
        
        searchTextFieldBox.backgroundColor = Theme.colour.fillTertiary
        searchTextFieldBox.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        searchImageView.tintColor = Theme.colour.labelSecondary
        
        searchTextField.backgroundColor = .clear
        searchTextField.textColor = Theme.colour.labelSecondary
        searchTextField.font = Theme.font.title3
        searchTextField.text = nil
        searchTextField.delegate = self
        
        clearSearchButton.isHidden = true
        clearSearchButton.tintColor = Theme.colour.labelSecondary
    }

    @objc func addCustomToken() {
        
        presenter.handle(.addCustomToken)
    }

    @objc func doneTapped() {
        
        presenter.handle(.done)
    }

    @objc func closeTapped() {
        
        presenter.handle(.dismiss)
    }
}

extension TokenPickerViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return viewModel?.filters().count ?? 0

        case CollectionTag.items.rawValue:
            
            return viewModel?.items().count ?? 0
            
        default:
            
            fatalError("Collection not implemented")
        }
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        collectionViewCell(at: indexPath, for: collectionView)
    }
}

extension TokenPickerViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
       
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:
            
            filterSelectedAt(indexPath: indexPath)
        case CollectionTag.items.rawValue:
            
            itemSelectedAt(indexPath: indexPath)
            
        default:
            
            fatalError("Collection not implemented")
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.tag == CollectionTag.items.rawValue else { return }
        
        dismissKeyboard()
    }
}

extension TokenPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
                
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return .init(width: 56, height: collectionView.frame.height)

        case CollectionTag.items.rawValue:
            
            return .init(width: collectionView.frame.width, height: 56)

        default:
            
            fatalError("Collection not implemented")
        }
    }
}

extension TokenPickerViewController: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        presenter.handle(.search(searchTerm: textField.text ?? ""))
    }
}

private extension TokenPickerViewController {
    
    func filterSelectedAt(indexPath: IndexPath) {
        
        guard let filter = viewModel?.filters()[indexPath.row] else { return }
        
        presenter.handle(.selectFilter(filter))
    }
    
    func itemSelectedAt(indexPath: IndexPath) {
        
        guard let item = viewModel?.items()[indexPath.row] else { return }
        
        guard case let TokenPickerViewModel.Item.token(token) = item else { return }
        
        presenter.handle(.selectItem(token))
    }
    
    func collectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        switch collectionView.tag {
            
        case CollectionTag.filters.rawValue:

            return filterCollectionViewCell(at: indexPath, for: collectionView)

        case CollectionTag.items.rawValue:
            
            return itemCollectionViewCell(at: indexPath, for: collectionView)
            
        default:
            
            fatalError("Collection not implemented")
        }
    }
    
    func filterCollectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        guard let filter = viewModel?.filters()[indexPath.item] else {
            fatalError()
        }
        
        let cell = collectionView.dequeue(
            TokenPickerFilterCell.self,
            for: indexPath
        )
        cell.update(
            with: filter
        )
        return cell
    }
    
    func itemCollectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        guard let item = viewModel?.items()[indexPath.item] else {
            fatalError()
        }
        
        switch item {
            
        case let .group(group):
            
            let cell = collectionView.dequeue(
                TokenPickerGroupCell.self,
                for: indexPath
            )
            cell.update(
                with: group,
                and: collectionView.frame.size.width
            )
            return cell
            
        case let .token(token):
            
            let cell = collectionView.dequeue(
                TokenPickerItemCell.self,
                for: indexPath
            )
            cell.update(
                with: token,
                and: collectionView.frame.size.width
            )
            return cell
        }
    }
    
    @objc func dismissKeyboard() {
        
        searchTextField.resignFirstResponder()
    }
}
