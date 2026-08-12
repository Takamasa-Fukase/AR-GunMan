//
//  WeaponUIResources.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/08/12.
//

import Foundation
import SwiftUI

struct WeaponUIResources {
    let weaponImageName: String
    let sightImageName: String
    let sightImageColor: Color
    
    private let bulletsCountImageBaseName: String
    
    init(
        weaponImageName: String,
        sightImageName: String,
        sightImageColor: Color,
        bulletsCountImageBaseName: String
    ) {
        self.weaponImageName = weaponImageName
        self.sightImageName = sightImageName
        self.sightImageColor = sightImageColor
        self.bulletsCountImageBaseName = bulletsCountImageBaseName
    }
    
    func bulletsCountImageName(_ count: Int) -> String {
        return bulletsCountImageBaseName + String(count)
    }
}
