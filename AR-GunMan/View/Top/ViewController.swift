//
//  ViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import AVFoundation
import PanModal

class ViewController: UIViewController {
    
    var replayFlag = false
    var pistolShoot = AVAudioPlayer()
    
    @IBOutlet weak var startButtonIcon: UIImageView!
    @IBOutlet weak var settingsButtonIcon: UIImageView!
    @IBOutlet weak var howToPlayButtonIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // マナーモードでも音を鳴らすようにする
            try audioSession.setCategory(.playback)
            
        } catch {
            print("error マナーモードでも音を鳴らすようにする設定失敗")
        }
        
        setAudioPlayer(forIndex: 1, resourceFileName: "westernPistolShoot")
        
        if #available(iOS 13.0, *) {
            startButtonIcon.image = UIImage(systemName: "target")
            settingsButtonIcon.image = UIImage(systemName: "target")
            howToPlayButtonIcon.image = UIImage(systemName: "target")
        } else {
            startButtonIcon.image = UIImage(named: "targetIcon")
            settingsButtonIcon.image = UIImage(named: "targetIcon")
            howToPlayButtonIcon.image = UIImage(named: "targetIcon")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
               
        if replayFlag {
            presentGameVC(animated: false)
        }
    }

    @IBAction func toGameButtonTapped(_ sender: Any) {
                
        CameraAuthModel.checkCameraAuthorization(vc: self)
        
        changeButtonIcon(startButtonIcon, isStartButtonTapped: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presentGameVC()
        }
        
    }
    
    @IBAction func toSettingButtonTapped(_ sender: Any) {
        
        changeButtonIcon(settingsButtonIcon)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        let navi = UINavigationController(rootViewController: vc)
        navi.setNavigationBarHidden(true, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presentPanModal(navi)
        }
    }
    
    @IBAction func toTutorialButtonTapped(_ sender: Any) {
        
        changeButtonIcon(howToPlayButtonIcon)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        
        vc.isBlurEffectEnabled = false
        
        let navi = UINavigationController(rootViewController: vc)
        navi.setNavigationBarHidden(true, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presentPanModal(navi)
        }
    }
    
    
    
    func presentGameVC(animated: Bool = true) {
        if #available(iOS 13.0, *) {
            startButtonIcon.image = UIImage(systemName: "target")
        } else {
            startButtonIcon.image = UIImage(named: "targetIcon")
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: animated)
    }
    
    
    func changeButtonIcon(_ imageView: UIImageView, isStartButtonTapped: Bool = false) {
        
        imageView.image = UIImage(named: "bulletsHole")
        
        pistolShoot.play()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "target")
            } else {
                imageView.image = UIImage(named: "targetIcon")
            }
        }
    }
    
}

extension ViewController: AVAudioPlayerDelegate {

    private func setAudioPlayer(forIndex index: Int, resourceFileName: String) {
        guard let path = Bundle.main.path(forResource: resourceFileName, ofType: "mp3") else {
            print("音源\(index)が見つかりません")
            return
        }
        do {
            switch index {
            case 1:
                pistolShoot = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                pistolShoot.prepareToPlay()
            
            default:
                break
            }
        } catch {
            print("音声セットエラー")
        }
    }
}
