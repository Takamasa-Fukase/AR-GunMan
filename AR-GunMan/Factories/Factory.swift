//
//  Factory.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/3/25.
//

import Data
import Domain

#if DEBUG
// TODO: FirebaseはProdとDevで両方用意してあるので、ビルド環境にMockを用意して、Prod, Dev, Mockみたいに3つに分けたい
typealias Factory = MockFactory
#else
typealias Factory = ProdFactory
#endif

protocol FactoryInterface {
    static func create() -> WeaponRepositoryInterface
    static func create() -> TutorialRepositoryInterface
    static func create() -> PermissionRepositoryInterface
    static func create() -> RankingRepositoryInterface
    static func create() -> GameTimerCreateUseCaseInterface
    static func create() -> RankingUseCaseInterface
    static func create() -> WeaponActionExecuteUseCaseInterface
    static func create() -> WeaponResourceGetUseCaseInterface
    static func create() -> WeaponStatusCheckUseCaseInterface
}
