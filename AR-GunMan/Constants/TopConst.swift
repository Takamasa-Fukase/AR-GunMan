//
//  TopConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation
import UIKit

final class TopConst {
    private static let targetIcon = UIImage(systemName: "target")
    private static let targetIconShot = UIImage(named: "bulletsHole")
    
    static let iconChangingSound: SoundType = .westernPistolShoot

    // TODO: 差し替えが終わったら消す
    static let iconRevertInterval: Double = 0.5
    
    static let iconRevertWaitingTimeMillisec: Int = 500

    static func targetIcon(isSwitched: Bool) -> UIImage? {
        return isSwitched ? targetIconShot : targetIcon
    }
}
