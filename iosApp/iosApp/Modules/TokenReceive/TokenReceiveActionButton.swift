// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class TokenReceiveActionButton: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    private var onTap: (() -> Void)?
    
    override func awakeFromNib() {

        super.awakeFromNib()
        
        iconImageView.backgroundColor = ThemeOG.color.background
        iconImageView.layer.cornerRadius = iconImageView.frame.size.width * 0.5

        nameLabel.applyStyle(.callout)
        
        guard gestureRecognizers?.isEmpty ?? true else { return }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    func update(
        with name: String,
        and image: UIImage?,
        onTap: @escaping () -> Void
    ) {
        
        nameLabel.text = name
        iconImageView.image = image
        
        self.onTap = onTap
    }
}

private extension TokenReceiveActionButton {
    
    @objc func viewTapped() {
        
        onTap?()
    }
}
