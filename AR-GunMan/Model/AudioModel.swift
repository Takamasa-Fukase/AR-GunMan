//
//  AudioModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import Foundation
import AVFoundation

class AudioModel {
    
    static var audioPlayers: [Sounds: AVAudioPlayer] = [:]
    
    static func playSound(of sound: Sounds) {
        audioPlayers[sound]?.currentTime = 0
        audioPlayers[sound]?.play()
        
        switch sound {
        case .pistolShoot, .bazookaShoot:
            vibration()
        default:
            break
        }
    }
    
    private static func vibration() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}

//起動時に呼ぶ初期化メソッドなど
extension AudioModel {
    
    static func initAudioPlayers() {
        Sounds.allCases.forEach({ sound in
            guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") else {
                print("音源\(sound.rawValue)が見つかりません")
                return
            }
            do {
                
                let audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer.prepareToPlay()
                
                AudioModel.audioPlayers[sound] = audioPlayer
                
                print("音声追加成功")
                
            } catch {
                print("音声セットエラー: \(sound.rawValue)")
            }
            
        })
        
        forceSoundOn()
    }
    
    private static func forceSoundOn() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // マナーモードでも音を鳴らすようにする
            try audioSession.setCategory(.playback)
            
        } catch {
            print("error マナーモードでも音を鳴らすようにする設定失敗")
        }
    }
 
}
