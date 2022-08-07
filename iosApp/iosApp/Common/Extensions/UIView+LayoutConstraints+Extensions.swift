// Created by web3dgn on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIView {
    
    enum Constraint {
        
        case layout(LayoutConstraint, priority: UILayoutPriority)
        case hugging(layoutAxis: NSLayoutConstraint.Axis, priority: UILayoutPriority)
        case compression(layoutAxis: NSLayoutConstraint.Axis, priority: UILayoutPriority)
    }
    
    struct LayoutConstraint {
        
        let layoutAnchor: LayoutAnchor
        let constant: LayoutConstant
    }
    
    enum LayoutAnchor {
        
        case leadingAnchor
        case trailingAnchor
        case leftAnchor
        case rightAnchor
        case centerXAnchor
        case topAnchor
        case bottomAnchor
        case centerYAnchor
        case widthAnchor
        case heightAnchor
    }
    
    enum LayoutConstant {
        
        case equalTo(constant: CGFloat)
        case greaterThanOrEqualTo(constant: CGFloat)
        case lessThanOrEqualTo(constant: CGFloat)
    }
}

extension UIView {
    
    func addConstraints(_ constraints: [Constraint]) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        constraints.forEach { constraint in
            
            switch constraint {
                
            case let .layout(layoutConstraint, priority):
                
                addLayoutConstraint(layoutConstraint, with: priority)
                
            case let .hugging(axis, priority):
                
                setContentHuggingPriority(priority, for: axis)

            case let .compression(axis, priority):
                
                setContentCompressionResistancePriority(priority, for: axis)
            }
        }
    }
}

extension Array where Element == UIView.Constraint {
    
    static var toEdges: [UIView.Constraint] = [
        .layout(anchor: .topAnchor),
        .layout(anchor: .bottomAnchor),
        .layout(anchor: .leadingAnchor),
        .layout(anchor: .trailingAnchor)
    ]
    
    static func toEdges(padding: CGFloat) -> [UIView.Constraint] {
        
        [
            .layout(anchor: .topAnchor, constant: .equalTo(constant: padding)),
            .layout(anchor: .bottomAnchor, constant: .equalTo(constant: padding)),
            .layout(anchor: .leadingAnchor, constant: .equalTo(constant: padding)),
            .layout(anchor: .trailingAnchor, constant: .equalTo(constant: padding))
        ]
    }
    
    func adding(_ constraint: UIView.Constraint) -> [UIView.Constraint] {
        
        var array = self
        array.append(constraint)
        return array
    }
}

private extension UIView {
    
    @discardableResult
    func addLayoutConstraint(
        _ layoutConstraint: LayoutConstraint,
        with priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        switch layoutConstraint.layoutAnchor {
            
        case .leadingAnchor:
            return applyLeadingAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .trailingAnchor:
            return applyTrailingAnchorConstraint(with: layoutConstraint, andPriority: priority)

        case .leftAnchor:
            return applyLeftAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .rightAnchor:
            return applyRightAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .centerXAnchor:
            return applyCenterXAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .topAnchor:
            return applyTopAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .bottomAnchor:
            return applyBottomAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .centerYAnchor:
            return applyCenterYAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .widthAnchor:
            return applyWidthAnchorConstraint(with: layoutConstraint, andPriority: priority)
            
        case .heightAnchor:
            return applyHeightAnchorConstraint(with: layoutConstraint, andPriority: priority)
        }
    }
    
    func applyLeadingAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = leadingAnchor.constraint(greaterThanOrEqualTo: parent.leadingAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = leadingAnchor.constraint(lessThanOrEqualTo: parent.leadingAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyTrailingAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = parent.trailingAnchor.constraint(equalTo: trailingAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = parent.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = parent.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyLeftAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = leftAnchor.constraint(equalTo: parent.leftAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = leftAnchor.constraint(greaterThanOrEqualTo: parent.leftAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = leftAnchor.constraint(lessThanOrEqualTo: parent.leftAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyRightAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = parent.rightAnchor.constraint(equalTo: rightAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = parent.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = parent.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyCenterXAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = parent.centerXAnchor.constraint(equalTo: centerXAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = parent.centerXAnchor.constraint(greaterThanOrEqualTo: centerXAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = parent.centerXAnchor.constraint(lessThanOrEqualTo: centerXAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyTopAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = topAnchor.constraint(equalTo: parent.topAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = topAnchor.constraint(greaterThanOrEqualTo: parent.topAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = topAnchor.constraint(lessThanOrEqualTo: parent.topAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyBottomAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = parent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = parent.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = parent.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
 
    func applyCenterYAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        guard let parent = superview else { return nil }
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            constraint = parent.centerYAnchor.constraint(equalTo: centerYAnchor, constant: constant)
        case let .greaterThanOrEqualTo(constant):
            constraint = parent.centerYAnchor.constraint(greaterThanOrEqualTo: centerYAnchor, constant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = parent.centerYAnchor.constraint(lessThanOrEqualTo: centerYAnchor, constant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyWidthAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            if constant == 0 {
                guard let parent = superview else { return nil }
                constraint = widthAnchor.constraint(equalTo: parent.widthAnchor, constant: constant)
            } else {
                constraint = widthAnchor.constraint(equalToConstant: constant)
            }
        case let .greaterThanOrEqualTo(constant):
            constraint = widthAnchor.constraint(greaterThanOrEqualToConstant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = widthAnchor.constraint(lessThanOrEqualToConstant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
    
    func applyHeightAnchorConstraint(
        with displayModel: LayoutConstraint,
        andPriority priority: UILayoutPriority
    ) -> NSLayoutConstraint? {
        
        let constraint: NSLayoutConstraint
        switch displayModel.constant {
        case let .equalTo(constant):
            if constant == 0 {
                guard let parent = superview else { return nil }
                constraint = heightAnchor.constraint(equalTo: parent.heightAnchor, constant: constant)
            } else {
                constraint = heightAnchor.constraint(equalToConstant: constant)
            }
        case let .greaterThanOrEqualTo(constant):
            constraint = heightAnchor.constraint(greaterThanOrEqualToConstant: constant)
        case let .lessThanOrEqualTo(constant):
            constraint = heightAnchor.constraint(lessThanOrEqualToConstant: constant)
        }
        constraint.priority = priority
        constraint.isActive = true
        
        return constraint
    }
}

extension UIView.Constraint {

    static func layout(
        anchor: UIView.LayoutAnchor,
        constant: UIView.LayoutConstant = .equalTo(constant: 0),
        priority: UILayoutPriority = .required
    ) -> Self {
        
        .layout(
            .init(layoutAnchor: anchor, constant: constant),
            priority: priority
        )
    }
    
    static func hugging(
        axis: NSLayoutConstraint.Axis,
        priority: UILayoutPriority = .defaultHigh
    ) -> Self {
        
        .hugging(layoutAxis: axis, priority: priority)
    }
    
    static func compression(
        axis: NSLayoutConstraint.Axis,
        priority: UILayoutPriority = .defaultHigh
    ) -> Self {
        
        .compression(layoutAxis: axis, priority: priority)
    }
}

extension UIView {

    func contraintToSuperView(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) {
        guard let sv = superview else { return }

        sv.addConstraints([
            leadingAnchor.constraint(equalTo: sv.leadingAnchor, constant: left),
            trailingAnchor.constraint(equalTo: sv.trailingAnchor, constant: right),
            topAnchor.constraint(equalTo: sv.topAnchor, constant: top),
            bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: bottom),
        ])
    }
}