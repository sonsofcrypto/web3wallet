// Created by web3d4v on 09/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension UIView {
    
    func animateAsIncomeMessage() {
        
        animate(
            from: .init(scaleX: 0.65, y: 0.65),
            to: .init(scaleX: 1.1, y: 1.1),
            duration: 0.175,
            onCompletion: { [weak self] _ in
                guard let self = self else { return }
                self.animate(
                    from: .init(scaleX: 1.1, y: 1.1),
                    to: .identity,
                    duration: 0.075
                )
            }
        )
    }
}

private extension UIView {
    
    func animate(
        from: CGAffineTransform,
        to: CGAffineTransform,
        delay: TimeInterval = 0,
        duration: TimeInterval = 0.15,
        onCompletion: ((Bool) -> Void)? = nil
    ) {
        
        transform = from
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.95,
            options: [
                .allowUserInteraction,
                .allowAnimatedContent,
                .beginFromCurrentState,
            ],
            animations: { [weak self] in
                guard let self = self else { return }
                self.transform = to
            },
            completion: onCompletion
        )
    }
    
    func animate2(
        from: CGAffineTransform,
        to: CGAffineTransform,
        duration: TimeInterval = 0.15,
        onCompletion: ((Bool) -> Void)? = nil
    ) {
        
        transform = from
        
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let self = self else { return }
                self.transform = to
            },
            completion: onCompletion
        )
    }
}
