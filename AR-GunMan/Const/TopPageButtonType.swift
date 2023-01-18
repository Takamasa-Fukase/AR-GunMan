//
//  TopPageButtonType.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 17/1/23.
//

import UIKit

enum TopPageButtonType {
    case start
    case ranking
    case howToPlay
    case settings
    
    var iconChangingSound: Sounds {
        switch self {
        case .start, .ranking, .howToPlay:
            return .westernPistolShoot
        case .settings:
            return .bazookaSet
        }
    }
    
    var iconRevertInterval: Double {
        switch self {
        case .start, .ranking, .howToPlay:
            return 0.5
        case .settings:
            return 0.25
        }
    }
    
    func targetIcon(isSwitched: Bool) -> UIImage? {
        return isSwitched ? TopConst.targetIconShot : TopConst.targetIcon
    }
    
    func toolBoxIcon(isSwitched: Bool) -> UIImage? {
        return isSwitched ? TopConst.toolBoxIconOpened : TopConst.toolBoxIconClosed
    }
}
