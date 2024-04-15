//
//  TopConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation
import UIKit

class TopConst {
    private static let targetIcon = UIImage(systemName: "target")
    private static let targetIconShot = UIImage(named: "bulletsHole")
    
    static let iconChangingSound: Sounds = .westernPistolShoot
    static let iconRevertInterval: Double = 0.5
    
    static func targetIcon(isSwitched: Bool) -> UIImage? {
        return isSwitched ? targetIconShot : targetIcon
    }
}
