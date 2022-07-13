//
//  Created by web3 on 23/04/2022.
//

import UIKit

class BaseViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        Theme.statusBarStyle.statusBarStyle(for: traitCollection.userInterfaceStyle)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
    }
}
