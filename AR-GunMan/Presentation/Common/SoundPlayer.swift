//
//  SoundPlayer.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/22.
//

import AVFoundation

protocol SoundPlayerInterface {
    func play(_ sound: SoundType)
}

final class SoundPlayer {
    static let shared = SoundPlayer()
    
    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]
    
    private init() {
        initAudioPlayers()
        forceSoundOn()
    }
    
    private func initAudioPlayers() {
        SoundType.allCases.forEach({ sound in
            guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") else {
                print("音源\(sound.rawValue)が見つかりません")
                return
            }
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.prepareToPlay()
                audioPlayers[sound] = audioPlayer
            } catch {
                print("音声セットエラー: \(sound.rawValue)")
            }
        })
    }
    
    private func playSound(of sound: SoundType) {
        audioPlayers[sound]?.currentTime = 0
        audioPlayers[sound]?.play()
    }
    
    private func playVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    private func forceSoundOn() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // マナーモードでも音を鳴らすようにする
            try audioSession.setCategory(.playback)
        } catch {
            print("forceSoundOn error: \(error)")
        }
    }
}

extension SoundPlayer: SoundPlayerInterface {
    func play(_ sound: SoundType) {
        playSound(of: sound)
        if sound.needsPlayVibration {
            playVibration()
        }
    }
}
