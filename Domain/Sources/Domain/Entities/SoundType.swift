//
//  SoundConst.swift
//  WeaponFiringSimulator
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

import Foundation

public enum SoundType: String, CaseIterable {
    case pistolAppear = "pistol_appear"
    case pistolFire = "pistol_fire"
    case pistolOutOfBullets = "pistol_out_of_bullets"
    case pistolReload = "pistol_reload"
    case targetHit = "target_hit"
    case bazookaAppear = "bazooka_appear"
    case bazookaReload = "bazooka_reload"
    case bazookaFire = "bazooka_fire"
    case bazookaExplosion = "bazooka_explosion"
    case startWhistle = "start_whistle"
    case endWhistle = "end_whistle"
    case rankingAppear = "ranking_appear"
    case targetAppearanceChange = "target_appearance_change"
    case westernPistolFire = "western_pistol_fire"
    
    public var needsPlayVibration: Bool {
        return self == .pistolFire || self == .bazookaFire
    }
}
