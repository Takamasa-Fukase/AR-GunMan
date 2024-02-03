//
//  TopPageButtonType.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 17/1/23.
//

import UIKit

enum TopPageButtonType {
    case start
    case settings
    case howToPlay
    
    var iconChangingSound: Sounds {
        switch self {
        case .start, .settings, .howToPlay:
            return .westernPistolShoot
        }
    }
    
    var iconRevertInterval: Double {
        switch self {
        case .start, .settings, .howToPlay:
            return 0.5
        }
    }
    
    func targetIcon(isSwitched: Bool) -> UIImage? {
        return isSwitched ? TopConst.targetIconShot : TopConst.targetIcon
    }
}
