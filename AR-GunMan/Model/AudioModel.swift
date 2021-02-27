//
//  AudioModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import Foundation
import AVFoundation

enum Sounds: String, CaseIterable {
    case pistolSet = "pistol-slide"
    case pistolShoot = "pistol-fire"
    case pistolOutBullets = "pistol-out-bullets"
    case pistolReload = "pistol-reload"
    case headShot = "headShot"
    case bazookaSet = "bazookaSet"
    case bazookaReload = "bazookaReload"
    case bazookaShoot = "bazookaShoot"
    case bazookaHit = "bazookaHit"
    case startWhistle = "startWhistle"
    case endWhistle = "endWhistle"
    case rankingAppear = "rankingAppear"
    case kyuiin = "kyuiin"
    case westernPistolShoot = "westernPistolShoot"
}

class AudioModel {
    
    static var audioPlayers: [Sounds: AVAudioPlayer] = [:]
    
    static func playSound(of sound: Sounds) {
        audioPlayers[sound]?.currentTime = 0
        audioPlayers[sound]?.play()
    }
}

//起動時に呼ぶ初期化メソッドなど
extension AudioModel {
    
    static func initAudioPlayers() {
        print("AudioModel init")
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
