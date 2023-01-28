//
//  CurrentWeapon.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 10/1/23.
//

import RxSwift
import RxCocoa

class CurrentWeapon {
    var weaponTypeChanged: Observable<WeaponType> {
        return typeRelay.asObservable()
    }
    var bulletsCountChanged: Observable<Int> {
        return bulletsHolder.bulletsCountChanged.asObservable()
    }
    var fired: Observable<Void> {
        return firedRelay.asObservable()
    }
    var weaponType: WeaponType {
        return typeRelay.value
    }
    
    private let typeRelay: BehaviorRelay<WeaponType>
    private var bulletsHolder: BulletsHolder
    private let firedRelay = PublishRelay<Void>()
    
    init(type: WeaponType) {
        self.typeRelay = BehaviorRelay<WeaponType>(value: type)
        self.bulletsHolder = BulletsHolder(type: type)
    }
    
    func fire() {
        guard bulletsHolder.canFire else {
            if weaponType != .bazooka {
                AudioUtil.playSound(of: .pistolOutBullets)
            }
            return
        }
        AudioUtil.playSound(of: weaponType.firingSound)
        bulletsHolder.decreaseBulletsCount()
        firedRelay.accept(Void())
        if weaponType == .bazooka {
            AudioUtil.playSound(of: .bazookaReload)
            bulletsHolder.startBazookaAutoReloading()
        }
    }
    
    func reload() {
        guard bulletsHolder.canReload else { return }
        if weaponType != .bazooka {
            AudioUtil.playSound(of: .pistolReload)
        }
        bulletsHolder.refillBulletsCount()
    }
    
    private func changeWeaponType(to newType: WeaponType) {
        typeRelay.accept(newType)
        AudioUtil.playSound(of: newType.weaponChangingSound)
        bulletsHolder = BulletsHolder(type: newType)
    }
}

extension CurrentWeapon: WeaponChangeDelegate {
    func weaponSelected(_ index: Int) {
        changeWeaponType(to: WeaponType.allCases[index])
    }
}
