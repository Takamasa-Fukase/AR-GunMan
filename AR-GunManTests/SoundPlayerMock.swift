//
//  SoundPlayerMock.swift
//  AR-GunManTests
//
//  Created by 深瀬 on 2024/05/22.
//

import Foundation

final class SoundPlayerMock: SoundPlayerInterface {
    var isPlayCalled = false
    var playedSound: SoundType?
    var playCalledCount = 0
    
    func play(_ sound: SoundType) {
        isPlayCalled = true
        playedSound = sound
        playCalledCount += 1
    }
}
