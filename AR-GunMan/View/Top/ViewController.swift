//
//  ViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/04.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import PanModal

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    var replayFlag = false
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var startButtonIcon: UIImageView!
    @IBOutlet weak var settingsButtonIcon: UIImageView!
    @IBOutlet weak var howToPlayButtonIcon: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
               
        if replayFlag {
            presentGameVC(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButtonIcon.image = Const.targetIcon
        settingsButtonIcon.image = Const.targetIcon
        howToPlayButtonIcon.image = Const.targetIcon

        let _ = startButton.rx.tap
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                CameraAuthModel.checkCameraAuthorization(vc: self)
                self.changeButtonIcon(self.startButtonIcon)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presentGameVC()
                }
            }).disposed(by: disposeBag)
        
        let _ = settingsButton.rx.tap
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.changeButtonIcon(self.settingsButtonIcon)
                
                let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                let navi = UINavigationController(rootViewController: vc)
                navi.setNavigationBarHidden(true, animated: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presentPanModal(navi)
                }
            }).disposed(by: disposeBag)
        
        let _ = howToPlayButton.rx.tap
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.changeButtonIcon(self.howToPlayButtonIcon)
                
                let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
                
                vc.isBlurEffectEnabled = false
                
                let navi = UINavigationController(rootViewController: vc)
                navi.setNavigationBarHidden(true, animated: false)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.presentPanModal(navi)
                }
            }).disposed(by: disposeBag)
    }
    
    func presentGameVC(animated: Bool = true) {
        startButtonIcon.image = Const.targetIcon
        
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: animated)
    }
    
    
    func changeButtonIcon(_ imageView: UIImageView) {
        imageView.image = Const.bulletsHoleIcon
        AudioModel.playSound(of: .westernPistolShoot)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            imageView.image = Const.targetIcon
        }
    }
    
}
