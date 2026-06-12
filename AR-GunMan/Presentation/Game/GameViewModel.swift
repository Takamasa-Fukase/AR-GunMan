//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 29/11/24.
//

import Foundation
import Observation
import Domain

@Observable
final class GameViewModel: GameViewModelInterface {
    var timeCount: Double = 30.00
    var currentWeapon: CurrentWeapon?
    
    // Binding
    var isTutorialViewPresented = false
    var isWeaponSelectViewPresented = false
    var isResultViewPresented = false
    var isWeaponChangeButtonEnabled = false
    
    @ObservationIgnored
    var score: Double = 0
}
