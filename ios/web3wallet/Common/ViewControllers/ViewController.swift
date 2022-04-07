//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        (view as? GradientView)?.colors = [
            UIColor(named: "gbGradientTop"),
            UIColor(named: "gbGradientBottom")
        ].compactMap { $0 }
        
    }

}
