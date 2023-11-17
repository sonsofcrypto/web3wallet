// Created by web3dgn on 21/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum TargetActionViewModel {
    
    case targetAction(TargetAction)

    // NOTE: TargetAction class is created to avoid a retain cycle.
    final class TargetAction {
        
        private (set) weak var target: AnyObject!
        let selector: Selector
        
        init(target: AnyObject, selector: Selector) {
            
            self.target = target
            self.selector = selector
        }
    }
}

extension UIView {
    
    func add(_ viewModel: TargetActionViewModel?) {
        guard let viewModel = viewModel else { return }
        guard case let TargetActionViewModel.targetAction(targetAction) = viewModel else {
            return
        }
        
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: targetAction.target, action: targetAction.selector)
        addGestureRecognizer(tap)
    }
}
