// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenPickerView: AnyObject {

    func update(with viewModel: TokenPickerViewModel)
}

final class TokenPickerViewController: BaseViewController {
    
    var presenter: TokenPickerPresenter!
    var context: TokenPickerWireframeContext!

    private var viewModel: TokenPickerViewModel?

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchContainerBox: UIView!
    @IBOutlet weak var searchTextFieldBox: UIView!
    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchTextField: TextField!
    @IBOutlet weak var dividerLineView: UIView!
    
    private var searchTerm = ""

    private var bottomKeyboardLayoutConstraint: NSLayoutConstraint!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension TokenPickerViewController: TokenPickerView {

    func update(with viewModel: TokenPickerViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title
        
        collectionView.reloadData()
        
        updateNavigationBarIcons()
    }
}

private extension TokenPickerViewController {
    
    func configureUI() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showKeyboard),
            name: UIApplication.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideKeyboard),
            name: UIApplication.keyboardWillHideNotification,
            object: nil
        )
        
        view.backgroundColor = Theme.colour.gradientBottom
        
        searchContainerBox.backgroundColor = Theme.colour.navBarBackground
        
        searchTextFieldBox.backgroundColor = Theme.colour.fillQuaternary
        searchTextFieldBox.layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        searchImageView.tintColor = Theme.colour.labelSecondary
        
        searchTextField.backgroundColor = .clear
        searchTextField.text = nil
        searchTextField.delegate = self
        searchTextField.placeholder = Localized("search")
        searchTextField.addDoneInputAccessoryView(
            with: .targetAction(.init(target: self, selector: #selector(clearSearchAnddismissKeyboard)))
        )

        //addCollectionViewBottomInset()
        collectionView.register(
            TokenPickerSectionCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(TokenPickerSectionCell.self)"
        )
        collectionView.setCollectionViewLayout(
            compositionalLayout(),
            animated: false
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // TODO: Smell
        bottomKeyboardLayoutConstraint = collectionView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor,
            constant: UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        )
        bottomKeyboardLayoutConstraint.priority = .required
        bottomKeyboardLayoutConstraint.isActive = true
    }
    
    @objc func showKeyboard() {
        addCollectionViewBottomInset()
    }
    
    @objc func hideKeyboard() {
        collectionView.contentInset = .zero
    }
    
    func addCollectionViewBottomInset() {
        // TODO: Smell
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        collectionView.contentInset = .init(top: 0, left: 0, bottom: bottom, right: 0)
    }
    
    func updateNavigationBarIcons() {
        
        guard let viewModel = viewModel else { return }
        
        if viewModel.allowMultiSelection {
            
            if viewModel.showAddCustomToken {
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: "plus".assetImage,
                    style: .plain,
                    target: self,
                    action: #selector(addCustomToken)
                )
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: Localized("done"),
                style: .plain,
                target: self,
                action: #selector(doneTapped)
            )
        } else {
            
            if (navigationController?.viewControllers.count ?? 0) > 1 {
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: "chevron.left".assetImage,
                    style: .plain,
                    target: self,
                    action: #selector(navBarLeftActionTapped)
                )
            } else {
                
                navigationItem.leftBarButtonItem = UIBarButtonItem(
                    image: .init(systemName: "xmark"),
                    style: .plain,
                    target: self,
                    action: #selector(navBarLeftActionTapped)
                )
            }
            
            if viewModel.showAddCustomToken {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    image: "plus".assetImage,
                    style: .plain,
                    target: self,
                    action: #selector(addCustomToken)
                )
            }
        }
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = viewModel.allowMultiSelection
    }

    @objc func addCustomToken() {
        
        presenter.handle(.addCustomToken)
    }

    @objc func doneTapped() {
        
        presenter.handle(.done)
    }

    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}

extension TokenPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return viewModel?.sections.count ?? 0
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
        
        collectionViewCell(at: indexPath, for: collectionView)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard
            let section = viewModel?.sections[indexPath.section]
        else { fatalError() }
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let supplementary = collectionView.dequeue(
                TokenPickerSectionCell.self,
                for: indexPath,
                kind: kind
            )
            supplementary.update(with: section)
            return supplementary
            
        default:
            fatalError("Unexpected supplementary idxPath: \(indexPath) \(kind)")
        }
    }
}

extension TokenPickerViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
       
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError()
        }
        
        switch section.items[indexPath.item] {
        
        case let .network(network):
            
            presenter.handle(.selectNetwork(network))

        case let .token(token):
                        
            presenter.handle(.selectToken(token))
        }
    }
}

extension TokenPickerViewController: UITextFieldDelegate {
        
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        presenter.handle(.search(searchTerm: textField.text ?? ""))
    }
}

private extension TokenPickerViewController {
        
    func collectionViewCell(
        at indexPath: IndexPath,
        for collectionView: UICollectionView
    ) -> UICollectionViewCell {
        
        guard let section = viewModel?.sections[indexPath.section] else {
            fatalError()
        }
        
        switch section.items[indexPath.item] {
        
        case let .network(network):
            
            let cell = collectionView.dequeue(
                TokenPickerNetworkCell.self,
                for: indexPath
            )
            cell.update(with: network)
            return cell

        case let .token(token):
                        
            let cell = collectionView.dequeue(
                TokenPickerTokenCell.self,
                for: indexPath
            )
            cell.update(with: token)
            return cell
        }
    }
    
    @objc func clearSearchAnddismissKeyboard() {
        
        searchTextField.text = ""
        dismissKeyboard()
    }

    @objc func dismissKeyboard() {
        
        searchTextField.resignFirstResponder()
    }
}

private extension TokenPickerViewController {
    
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { [weak self] idx, _ in
            
            guard let self = self else { return nil }
            
            guard let section = self.viewModel?.sections[idx] else { return nil }
            
            switch section.type {
            case .networks:
                return self.makeNetworkItemsCollectionLayoutSection()
            case .tokens:
                return self.makeTokenItemsCollectionLayoutSection()
            }
        }

        return layout
    }
    
    func makeNetworkItemsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(144),
            heightDimension: .absolute(56)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = Theme.constant.padding.half
        section.contentInsets = .init(
            top: 0,
            leading: Theme.constant.padding,
            bottom: 0,
            trailing: Theme.constant.padding
        )
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerItem]

        return section
    }
    
    func makeTokenItemsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(56)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(44)
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
