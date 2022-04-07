//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

extension UIButton {

    func removeAllTargets() {
        allTargets.forEach {
            self.removeTarget($0, action: nil, for: .touchUpInside)
        }
    }
}
