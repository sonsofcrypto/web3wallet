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

    private var backgroundGradientTopConstraint: NSLayoutConstraint?
    private var backgroundGradientHeightConstraint: NSLayoutConstraint?

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
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        updateBackgroundGradientTopConstraint()
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        navigationController?.showBottomLine(false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    
        super.viewDidDisappear(animated)
        
        navigationController?.showBottomLine(true)
    }
}

extension TokenPickerViewController: TokenPickerView {

    func update(with viewModel: TokenPickerViewModel) {

        self.viewModel = viewModel
        
        title = viewModel.title
        
        collectionView.reloadData()
        
        updateNavigationBarIcons()
        
        updateBackgroundGradient(after: 0.05)
    }
}

private extension TokenPickerViewController {
    
    func configureUI() {
        
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
            with: .targetAction(.init(target: self, selector: #selector(dismissKeyboard)))
        )
                
        dividerLineView.backgroundColor = navigationController?.bottomLineColor
        
        collectionView.register(
            TokenPickerGroupCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "\(TokenPickerGroupCell.self)"
        )

        collectionView.setCollectionViewLayout(
            UICollectionViewCompositionalLayout(section: makeItemsCollectionLayoutSection()),
            animated: false
        )
        
        addCustomBackgroundGradientView()        
    }
    
    func updateNavigationBarIcons() {
        
        guard let viewModel = viewModel else { return }
        
        if viewModel.allowMultiSelection {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: "plus".assetImage,
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
            collectionView.allowsMultipleSelection = viewModel.allowMultiSelection
        } else {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: Localized("close"),
                style: .plain,
                target: self,
                action: #selector(closeTapped)
            )
        }
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
    
    func updateBackgroundGradient(after delay: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.updateBackgroundGradient()
        }
    }
    
    func updateBackgroundGradient() {
        
        updateBackgroundGradientTopConstraint()
        backgroundGradientHeightConstraint?.constant = backgroundGradientHeight
    }
    
    func updateBackgroundGradientTopConstraint() {
        
        let constant: CGFloat
        if collectionView.contentOffset.y < 0 {
            constant = 0
        } else {
            constant = -collectionView.contentOffset.y
        }
        backgroundGradientTopConstraint?.constant =  constant
    }
}

extension TokenPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return viewModel?.sections().count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        guard let section = viewModel?.sections()[section] else {
            return 0
        }

        return section.items.count
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
            let section = viewModel?.sections()[indexPath.section]
        else { fatalError() }
        
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            
            let supplementary = collectionView.dequeue(
                TokenPickerGroupCell.self,
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
       
        guard let section = viewModel?.sections()[indexPath.section] else {
            fatalError()
        }
        let token = section.items[indexPath.item]
        presenter.handle(.selectItem(token))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        updateBackgroundGradientTopConstraint()
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
        
        guard let section = viewModel?.sections()[indexPath.section] else {
            fatalError()
        }
        
        let token = section.items[indexPath.item]
                    
        let cell = collectionView.dequeue(
            TokenPickerItemCell.self,
            for: indexPath
        )
        cell.update(
            with: token
        )
        return cell
    }
    
    @objc func dismissKeyboard() {
        
        searchTextField.resignFirstResponder()
    }
}

private extension TokenPickerViewController {
    
    func makeItemsCollectionLayoutSection() -> NSCollectionLayoutSection {
        
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

extension TokenPickerViewController: UIScrollViewDelegate {

    func addCustomBackgroundGradientView() {

        // 1 - Add gradient
        let backgroundGradient = GradientView()
        backgroundGradient.isDashboard = true
        view.insertSubview(backgroundGradient, at: 0)
        
        backgroundGradient.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = backgroundGradient.topAnchor.constraint(
            equalTo: searchContainerBox.bottomAnchor
        )
        self.backgroundGradientTopConstraint = topConstraint
        topConstraint.isActive = true

        backgroundGradient.leadingAnchor.constraint(
            equalTo: view.leadingAnchor
        ).isActive = true

        backgroundGradient.trailingAnchor.constraint(
            equalTo: view.trailingAnchor
        ).isActive = true

        let heightConstraint = backgroundGradient.heightAnchor.constraint(
            equalToConstant: backgroundGradientHeight
        )
        self.backgroundGradientHeightConstraint = heightConstraint
        heightConstraint.isActive = true
    }

    var backgroundGradientHeight: CGFloat {
        
        if collectionView.frame.size.height > collectionView.contentSize.height {
            
            return collectionView.frame.size.height
        } else {
            
            return collectionView.contentSize.height
        }
    }
}
