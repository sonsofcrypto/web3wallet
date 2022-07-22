// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class Button: UIButton {
    
    var style: Style = .primary {
        didSet { configure(for: style) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure(for: style)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(for: style)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        super.traitCollectionDidChange(previousTraitCollection)
        
        configure(for: style)
    }
    
    override var intrinsicContentSize: CGSize {
        
        var size = super.intrinsicContentSize
        
        switch style {
        case .primary:
            size.height = Theme.constant.buttonPrimaryHeight
        case .secondarySmall:
            size.height = Theme.constant.buttonSecondarySmallHeight
        case .dashboardAction:
            size.height = Theme.constant.buttonDashboardActionHeight
        }
        
        return size
    }
}

extension Button {
    
    enum Style {
        case primary
        case secondarySmall(leftImage: UIImage?)
        case dashboardAction(leftImage: UIImage?)
    }
}

private extension Button {
    
    func configure(for style: Style = .primary) {
        
        switch style {
        case .primary:
            var configuration = UIButton.Configuration.plain()
            configuration.titleTextAttributesTransformer = .init{ incoming in
                var outgoing = incoming
                outgoing.font = Theme.font.title3
                return outgoing
            }
            configuration.titlePadding = Theme.constant.padding * 0.5
            configuration.imagePadding = Theme.constant.padding * 0.5
            self.configuration = configuration
            updateConfiguration()
            backgroundColor = Theme.colour.buttonBackgroundPrimary
            tintColor = Theme.colour.buttonPrimaryText
            layer.cornerRadius = Theme.constant.cornerRadiusSmall
            setTitleColor(Theme.colour.buttonPrimaryText, for: .normal)
        case let .secondarySmall(leftImage):
            updateSecondaryStyle(leftImage: leftImage)
            layer.cornerRadius = Theme.constant.buttonSecondarySmallHeight.half
        case let .dashboardAction(leftImage):
            updateSecondaryStyle(leftImage: leftImage)
            layer.cornerRadius = Theme.constant.buttonDashboardActionHeight.half
        }
        invalidateIntrinsicContentSize()
    }
    
    func updateSecondaryStyle(leftImage: UIImage?) {
        
        var configuration = UIButton.Configuration.plain()
        configuration.titleTextAttributesTransformer = .init{ incoming in
            var outgoing = incoming
            outgoing.font = Theme.font.footnote
            return outgoing
        }
        configuration.titlePadding = Theme.constant.padding * 0.5
        configuration.imagePadding = Theme.constant.padding * 0.5
        self.configuration = configuration
        updateConfiguration()
        
        backgroundColor = .clear
        tintColor = Theme.colour.buttonSecondaryText
        layer.borderWidth = 0.5
        layer.borderColor = Theme.colour.buttonSecondaryText.cgColor
        setTitleColor(Theme.colour.buttonSecondaryText, for: .normal)
        titleLabel?.textAlignment = .natural
        
        if let leftImage = leftImage {
            
            setImage(
                leftImage.withRenderingMode(
                    .alwaysTemplate
                ).withTintColor(
                    Theme.colour.buttonSecondaryText
                ),
                for: .normal
            )
        }
        
    }
}

final class VerticalButton: Button {
    
    override var style: Button.Style {
        
        didSet {
            
            super.style = style
        }
    }

    override func layoutSubviews() {
        
        super.layoutSubviews()

        guard let imageView = self.imageView, let label = self.titleLabel else {
            return
        }
        
        backgroundColor = Theme.colour.labelTertiary

        imageView.center.x = bounds.width / 2
        imageView.center.y = bounds.height * 0.3333

        // TODO: Remove this hack. Introduced coz color and font were on being
        // set when setting from `AccountHeaderCell`
        label.apply(style: .footnote)
        label.textAlignment = .center

        label.bounds.size.width = bounds.width
        label.bounds.size.height = bounds.height * 0.3333
        label.center.x = bounds.width / 2
        label.center.y = bounds.height - label.bounds.height / 2 - 4
    }
}
