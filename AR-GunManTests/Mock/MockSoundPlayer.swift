//
//  MockSoundPlayer.swift
//  AR-GunManTests
//
//  Created by 深瀬 on 2024/05/22.
//

import Foundation

final class MockSoundPlayer: SoundPlayerInterface {
    var playedSounds: [SoundType] = []
    
    func play(_ sound: SoundType) {
        playedSounds.append(sound)
    }
}
