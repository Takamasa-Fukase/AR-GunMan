//
//  WeaponStatusUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/09.
//

import Foundation
import RxCocoa

class WeaponStatusUtil {
    
    //武器発射の結果を作成
    static func createWeaponFiringResult(currentWeapon: WeaponTypes,
                                         pistolBulletsCount: BehaviorRelay<Int>,
                                         bazookaBulletsCount: BehaviorRelay<Int>,
                                         excuteBazookaAutoReloading: (() -> Void)
    ) -> WeaponFiringResult {
        var resultType: WeaponFiringResultType?
        var remainingBulletsCount: Int?
         
        switch currentWeapon {
        case .pistol:
            if hasBullets(pistolBulletsCount.value) {
                //弾を発射するので残弾数を更新
                let _remainingBulletsCount = pistolBulletsCount.value - 1
                remainingBulletsCount = _remainingBulletsCount
                pistolBulletsCount.accept(_remainingBulletsCount)
                resultType = .fired
            }else {
                remainingBulletsCount = 0
                resultType = .noBullets
            }
            
        case .bazooka:
            if hasBullets(bazookaBulletsCount.value) {
                //弾を発射するので残弾数を更新
                let _remainingBulletsCount = bazookaBulletsCount.value - 1
                remainingBulletsCount = _remainingBulletsCount
                bazookaBulletsCount.accept(_remainingBulletsCount)
                resultType = .fired
                //バズーカのリロードは毎回自動で行う
                excuteBazookaAutoReloading()
            }else {
                remainingBulletsCount = 0
                resultType = .noBullets
            }
        }

        return WeaponFiringResult(result: resultType ?? .canceled,
                                  weapon: currentWeapon,
                                  remainingBulletsCount: remainingBulletsCount ?? 0)
        
        
    }
    
    
    //武器リロードの結果を作成
    static func createWeaponReloadingResult(currentWeapon: WeaponTypes,
                                            pistolBulletsCount: BehaviorRelay<Int>,
                                            bazookaBulletsCount: BehaviorRelay<Int>
    ) -> WeaponReloadingResult {
        var resultType: WeaponReloadingResultType?

        //現在の武器の弾が0の場合のみリロードを許可する
        switch currentWeapon {
        case .pistol:
            if !hasBullets(pistolBulletsCount.value) {
                //残弾数をMAXに補充
                pistolBulletsCount.accept(GameConst.pistolBulletsCapacity)
                resultType = .completed
            }else {
                resultType = .canceled
            }
            
        case .bazooka:
            if !hasBullets(bazookaBulletsCount.value) {
                //残弾数をMAXに補充
                bazookaBulletsCount.accept(GameConst.bazookaBulletsCapacity)
                resultType = .completed
            }else {
                resultType = .canceled
            }
        }

        return WeaponReloadingResult(result: resultType ?? .canceled,
                                     weapon: currentWeapon)
    }
    
    
    //武器切り替え結果を作成
    static func createWeaponSwitchingResult(currentWeapon: WeaponTypes,
                                   selectedWeapon: WeaponTypes,
                                   pistolBulletsCount: BehaviorRelay<Int>,
                                   bazookaBulletsCount: BehaviorRelay<Int>
    ) -> WeaponSwitchingResult {
        var switched: Bool {
            return !(currentWeapon == selectedWeapon)
        }
        var bulletsCount: Int {
            switch selectedWeapon {
            case .pistol:
                return pistolBulletsCount.value
            case .bazooka:
                return bazookaBulletsCount.value
            }
        }
        return WeaponSwitchingResult(switched: switched,
                                     weapon: selectedWeapon,
                                     bulletsCount: bulletsCount)
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
