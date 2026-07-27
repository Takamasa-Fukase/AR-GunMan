//
//  WeaponResources.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2026/06/30.
//

import Foundation
import SwiftUI

struct WeaponResources {
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
    
    public func bulletsCountImageName(_ count: Int) -> String {
        return bulletsCountImageBaseName + String(count)
    }
}
