// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsView: AnyObject {

    func update(with viewModel: CultProposalsViewModel)
}

final class CultProposalsViewController: BaseViewController {

    var presenter: CultProposalsPresenter!

    private var viewModel: CultProposalsViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        configureUI()
        
        presenter?.present()
    }
}

extension CultProposalsViewController: CultProposalsView {

    func update(with viewModel: CultProposalsViewModel) {
        
        self.viewModel = viewModel
        
        title = viewModel.title
        
        collectionView.reloadData()
    }
}

extension CultProposalsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        viewModel?.sections.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        guard let section = viewModel?.sections[section] else { return 0 }
        return section.items.count
    }
    

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let section = viewModel?.sections[indexPath.section] else { fatalError() }
        let viewModel = section.items[indexPath.item]
        
        switch section.type {
        case .pending:
            let cell = collectionView.dequeue(CultProposalCellPending.self, for: indexPath)
            return cell.update(with: viewModel, handler: makeCultProposalCellPendingHandler())
        case .closed:
            let cell = collectionView.dequeue(CultProposalCellClosed.self, for: indexPath)
            return cell.update(with: viewModel)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        switch kind {
        case "header":
            
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: String(describing: CultProposalHeaderSupplementaryView.self),
                for: indexPath
            ) as? CultProposalHeaderSupplementaryView else {
                
                return CultProposalHeaderSupplementaryView()
            }
            
            guard let section = viewModel?.sections[indexPath.section] else { fatalError() }
            headerView.update(with: section)
            return headerView
            
        default:
            assertionFailure("Unexpected element kind: \(kind).")
            return UICollectionReusableView()
        }
    }
}

extension CultProposalsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        guard let section = viewModel?.sections[indexPath.section] else { return }
        let item = section.items[indexPath.row]
        presenter.handle(.selectProposal(id: item.id))
    }
}

private extension CultProposalsViewController {
    
    func configureUI() {
        
        collectionView.setCollectionViewLayout(
            makeCompositionalLayout(),
            animated: false
        )
        collectionView.register(
            CultProposalHeaderSupplementaryView.self,
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: String(describing: CultProposalHeaderSupplementaryView.self)
        )
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func makeCompositionalLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout {
            
            [weak self] sectionIndex, _ in
            
            guard let self = self, let sections = self.viewModel?.sections else { return nil }
            
            let section = sections[sectionIndex]
            
            return self.makeCollectionLayoutSection(
                isHorizontalScrolling: section.type == .pending
            )
        }
    }
  
    func makeCollectionLayoutSection(
        isHorizontalScrolling: Bool
    ) -> NSCollectionLayoutSection {
        
        let padding = Theme.constant.padding

        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(1)
        )
        let item = NSCollectionLayoutItem(
            layoutSize: itemSize
        )
        item.contentInsets = .init(
            top: padding.half,
            leading: isHorizontalScrolling ? 0 : padding.half,
            bottom: padding.half,
            trailing: isHorizontalScrolling ? 0 : padding.half
        )
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(
                isHorizontalScrolling ?
                view.frame.size.width - Theme.constant.padding * 2 :
                view.frame.size.width - Theme.constant.padding
            ),
            heightDimension: .estimated(100)
        )
        let outerGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        //outerGroup.contentInsets = .paddingHalf
        
        // Section
        let section = NSCollectionLayoutSection(group: outerGroup)
        section.contentInsets = isHorizontalScrolling ?
            .init(
                top: Theme.constant.padding,
                leading: Theme.constant.padding,
                bottom: 0,
                trailing: Theme.constant.padding
            ) :
            .paddingHalf
        section.interGroupSpacing = isHorizontalScrolling ?
        Theme.constant.padding.half :
        Theme.constant.padding
        
        if isHorizontalScrolling {
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        }
        
        let headerItemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(100)
        )
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerItemSize,
            elementKind: "header",
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [headerItem]
        
        return section
    }
}

private extension CultProposalsViewController {

    func makeCultProposalCellPendingHandler() -> CultProposalCellPending.Handler {
        
        .init(
            approveProposal: makeApproveProposal(),
            rejectProposal: makeRejectProposal()
        )
    }
    
    func makeApproveProposal() -> (String) -> Void {
        
        {
            [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.approveProposal(id: id))
        }
    }
    
    func makeRejectProposal() -> (String) -> Void {
        
        {
            [weak self] id in
            guard let self = self else { return }
            self.presenter.handle(.rejectProposal(id: id))
        }
    }

}
