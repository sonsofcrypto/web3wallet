//
// Created by anon on 01/10/2023.
//

import UIKit

extension UIControl {

    func addTar(
        _ target: Any?,
        action: Selector,
        for controlEvents: UIControl.Event = .touchUpInside
    ) {
        addTarget(target, action: action, for: controlEvents)
    }

    func removeAllTargets(_ controlEvents: UIControl.Event = .touchUpInside) {
        allTargets.forEach { removeTarget($0, action: nil, for: controlEvents) }
    }

}
