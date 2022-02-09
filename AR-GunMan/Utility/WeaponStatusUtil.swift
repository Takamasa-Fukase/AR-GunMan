//
//  WeaponStatusUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/09.
//

import Foundation

class WeaponStatusUtil {
    
    //武器発射の可否
    static func chackFireAvailable(gameStatus: GameStatus,
                                   currentWeapon: WeaponTypes,
                                   pistolBulletsCount: Int,
                                   bazookaBulletsCount: Int
    ) -> WeaponFiringReaction {
        
        //現在のゲームステータスがstartか（それ以外はunavailableを返す）
        if gameStatus != .start { return .fireUnavailable }
        
        //現在の武器の弾が0じゃないか（0ならnoBulletsを返す）
        switch currentWeapon {
        case .pistol:
            if hasBullets(pistolBulletsCount) {
                return .fireAvailable
            }else {
                return .noBullets
            }
        case .bazooka:
            if hasBullets(bazookaBulletsCount) {
                return .fireAvailable
            }else {
                return .noBullets
            }
        default:
            return .fireUnavailable
        }
    }
    
    //リロードの可否
    static func chackReloadAvailable(gameStatus: GameStatus,
                                   currentWeapon: WeaponTypes,
                                   pistolBulletsCount: Int
    ) -> Bool {
        
        //現在のゲームステータスがstartか（それ以外はfalseを返す）
        if gameStatus != .start { return false }
        
        //現在の武器の弾が0かどうか（0以外ならfalseを返す）
        switch currentWeapon {
        case .pistol:
            return !hasBullets(pistolBulletsCount)
        default:
            return false
        }
    }
    
    
    //MARK: - Private Methods
    private static func hasBullets(_ bulletsCount: Int) -> Bool {
        if bulletsCount > 0 {
            return true
        }else {
            return false
        }
    }
}
