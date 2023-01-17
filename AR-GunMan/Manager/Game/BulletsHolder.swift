//
//  BulletsHolder.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 12/1/23.
//

import RxSwift
import RxCocoa

class BulletsHolder {
    private var type: WeaponType
    private let bulletsCount: BehaviorRelay<Int>
    private var isBazookaReloading = false
    
    var bulletsCountChanged: Observable<Int> {
        return bulletsCount.asObservable()
    }
    
    var canFire: Bool {
        return bulletsCount.value > 0
    }
    
    var canReload: Bool {
        return bulletsCount.value <= 0 && !isBazookaReloading
    }
    
    init(type: WeaponType) {
        self.type = type
        self.bulletsCount = BehaviorRelay<Int>(value: type.bulletsCapacity)
    }
    
    func decreaseBulletsCount() {
        bulletsCount.accept(
            bulletsCount.value - 1
        )
    }
    
    func refillBulletsCount() {
        bulletsCount.accept(
            type.bulletsCapacity
        )
    }
    
    func startBazookaAutoReloading() {
        isBazookaReloading = true
        // バズーカは自動リロード（3.2秒後に完了）
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            self.refillBulletsCount()
            self.isBazookaReloading = false
        }
    }
}
