//
//  GameState.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//

import Foundation

class GameState {
    var timer: Timer?
    
    //count
    let targetCount: Observable<Int> // = 50
    let pistolBulletsCount: Observable<Int> // = 7
    let bazookaRocketCount: Observable<Int> // = 1
    let explosionCount: Observable<Int> // = 0
    
    let timeCount: Double = 30.00
    
    //score
    let pistolPoint = 0.0
    let bazookaPoint = 0.0
    
    //nodeAnimation
    let toggleActionInterval = 0.2
    let lastCameraPos: (Float, Float, Float) = (0, 0, 0)
    let isPlayerRunning = false
    let lastPlayerStatus = false
    
    var currentWeapon: WeaponTypes = .pistol
    
    var isShootEnabled = false
    
    init() {
        
    }
}
