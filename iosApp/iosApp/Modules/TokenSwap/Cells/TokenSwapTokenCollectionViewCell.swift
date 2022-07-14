// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenSwapTokenCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tokenFrom: TokenSwapTokenView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tokenTo: TokenSwapTokenView!
    
    struct Handler {

        let onTokenFromAmountChanged: ((Double) -> Void)?
        let onTokenToAmountChanged: ((Double) -> Void)?
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()

        imageView.superview?.layer.cornerRadius = Theme.constant.cornerRadius.half.half
        imageView.superview?.backgroundColor = Theme.colour.labelQuaternary
        
        imageView.tintColor = Theme.colour.labelSecondary
        imageView.image = .init(systemName: "arrow.down")
        imageView.isHidden = false
        
        loadingIndicator.isHidden = true
        loadingIndicator.color = Theme.colour.labelSecondary
    }
    
    override func resignFirstResponder() -> Bool {
        
        tokenFrom.resignFirstResponder() || tokenTo.resignFirstResponder()
    }
}

extension TokenSwapTokenCollectionViewCell {
    
    func update(
        with viewModel: TokenSwapViewModel.Swap,
        handler: Handler
    ) {
    
        loadingIndicator.stopAnimating()
        loadingIndicator.isHidden = true
        imageView.isHidden = false

        tokenFrom.update(
            with: viewModel.tokenFrom
        ) {
            [weak self] amount in
            guard let self = self else { return }
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            self.imageView.isHidden = true
            handler.onTokenFromAmountChanged?(amount)
        }
        
        tokenTo.update(
            with: viewModel.tokenTo
        ) {
            [weak self] amount in
            guard let self = self else { return }
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            self.imageView.isHidden = true
            handler.onTokenToAmountChanged?(amount)
        }
    }
}
