//
//  TopConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation
import UIKit

class TopConst {
    static var targetIcon: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "target")
        } else {
            return UIImage(named: "targetIcon")
        }
    }
    
    static let bulletsHoleIcon = UIImage(named: "bulletsHole")
}
