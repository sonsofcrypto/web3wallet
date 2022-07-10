// Created by web3d4v on 08/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class FeedPickerView: UIView {
    
    @IBOutlet weak var feesView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    
    private weak var presenter: TokenSendPresenter?
    private var fees: [TokenSendViewModel.Fee] = []
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        isHidden = true
                
        feesView.layer.cornerRadius = Theme.constant.cornerRadius
        feesView.clipsToBounds = true
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        feesView.insertSubview(blurEffectView, at: 0)
        blurEffectView.addConstraints(.toEdges)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        addGestureRecognizer(tapGesture)
    }

    func present(
        with fees: [TokenSendViewModel.Fee],
        presenter: TokenSendPresenter,
        at topRightAnchor: CGPoint = .init(x: Theme.constant.padding, y: 96)
    ) {
        self.presenter = presenter
        
        topConstraint.constant = topRightAnchor.y + feesView.frame.height
        trailingConstraint.constant = topRightAnchor.x
        
        update(fees: fees)
        
        isHidden = false
    }
}

private extension FeedPickerView {
    
    func update(fees: [TokenSendViewModel.Fee]) {
        
        assert(fees.count == 3, "Only 3 fees are supported")
        
        self.fees = fees
        
        for (index, fee) in fees.enumerated() {
            
            let stack = stackView.arrangedSubviews.first{ $0.tag == index } as? UIStackView
            updateItem(stack, with: fee)
        }
    }
    
    func updateItem(_ stackView: UIStackView?, with fee: TokenSendViewModel.Fee) {
        
        let nameLabel = stackView?.arrangedSubviews.first{ $0.tag == 1 } as? UILabel
        nameLabel?.font = Theme.font.body
        nameLabel?.textColor = Theme.colour.labelPrimary
        nameLabel?.text = fee.name

        let valueLabel = stackView?.arrangedSubviews.first{ $0.tag == 2 } as? UILabel
        valueLabel?.font = Theme.font.body
        valueLabel?.textColor = Theme.colour.labelPrimary
        valueLabel?.text = fee.value
        
        stackView?.add(.targetAction(.init(target: self, selector: #selector(feeTapped(_:)))))
    }
}

private extension FeedPickerView {
    
    @objc func feeTapped(_ sender: UITapGestureRecognizer) {
        
        guard let tag = sender.view?.tag else { return }
        
        let fee = fees[tag]
        
        presenter?.handle(.feeChanged(to: fee.id))
        
        dismissPicker()
    }
    
    @objc func dismissPicker() {
        
        isHidden = true
    }
}
