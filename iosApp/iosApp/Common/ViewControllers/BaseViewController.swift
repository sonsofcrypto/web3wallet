//
//  Created by web3 on 23/04/2022.
//

import UIKit

class BaseViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        Theme.statusBarStyle.statusBarStyle(for: traitCollection.userInterfaceStyle)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        #if DEBUG
        print("[DEBUG][\(String(describing: self))] viewDidAppear")
        #endif
    }

    deinit {
        #if DEBUG
        print("[DEBUG][\(String(describing: self))] deinit")
        #endif
    }
}
