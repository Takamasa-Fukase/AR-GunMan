//
//  GameModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/14.
//

import Foundation

enum GameStatus {
    case pause
    case playing
    case finish
}

enum WeaponFiringResultType {
    case fired
    case canceled
    case noBullets
}

enum WeaponReloadingResultType {
    case completed
    case canceled
}

struct WeaponFiringResult {
    let result: WeaponFiringResultType
    let weapon: WeaponTypes
    let remainingBulletsCount: Int
}

struct WeaponReloadingResult {
    let result: WeaponReloadingResultType
    let weapon: WeaponTypes
}

struct WeaponSwitchingResult {
    let switched: Bool
    let weapon: WeaponTypes
    let bulletsCount: Int
}
