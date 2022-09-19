//
//  Created by web3 on 23/04/2022.
//

import UIKit

class BaseViewController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        Theme.statusBarStyle.statusBarStyle(for: traitCollection.userInterfaceStyle)
    }

    deinit {
        #if DEBUG
        print("[DEBUG][ViewController] deinit \(String(describing: self))")
        #endif
    }
}
