//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import Foundation

extension Array {

    func first(n: Int) -> Array {
        guard count > n else {
            return self
        }
        return Array(self[0..<n])
    }
    
    func last(n: Int) -> Array {
        guard count > n else {
            return self
        }
        return Array(self[count - n..<count])
    }
}
