//
//  BulletsCountUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/09.
//

import Foundation

class BulletsCountUtil {
    static func hasBullets(_ bulletsCount: Int) -> WeaponFiringReaction {
        if bulletsCount > 0 {
            return .fireAvailable
        }else {
            return .noBullets
        }
    }
}
