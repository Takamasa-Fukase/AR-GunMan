//
//  SoundPlayer.swift
//  Infrastructure
//
//  Created by ウルトラ深瀬 on 2026/06/10.
//

import AVFoundation
import Presentation

public final class SoundPlayer: SoundPlayerInterface {
    public static let shared = SoundPlayer()
    
    private var audioPlayers: [SoundType: AVAudioPlayer] = [:]
    
    private init() {
        setup()
    }
    
    public func play(_ sound: SoundType) {
        playSound(of: sound)
        if sound.needsPlayVibration {
            playVibration()
        }
    }
    
    // MARK: Private Methods
    private func setup() {
        initAudioPlayers()
        forceSoundOn()
    }
    
    private func initAudioPlayers() {
        if !audioPlayers.isEmpty {
            audioPlayers.forEach { _, player in
                player.stop()
            }
            audioPlayers.removeAll()
        }
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
    
    private func forceSoundOn() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // マナーモードでも音を鳴らすようにする
            try audioSession.setCategory(.playback)
        } catch {
            print("forceSoundOn error: \(error)")
        }
    }
    
    private func playSound(of sound: SoundType) {
        audioPlayers[sound]?.currentTime = 0
        audioPlayers[sound]?.play()
    }
    
    private func playVibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
