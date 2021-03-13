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
    
    let viewModel = TopViewModel()
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
        
        //input
        let _ = startButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.start)
            }).disposed(by: disposeBag)
        
        let _ = settingsButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.settings)
            }).disposed(by: disposeBag)
        
        let _ = howToPlayButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.howToPlay)
            }).disposed(by: disposeBag)
        
        //output
        let _ = viewModel.isShotButtonIcon
            .subscribe(onNext: { [weak self] (type, bool) in
                guard let self = self else {return}
                let image = bool ? Const.bulletsHoleIcon : Const.targetIcon
                switch type {
                case .start:
                    self.startButtonIcon.image = image
                case .settings:
                    self.settingsButtonIcon.image = image
                case .howToPlay:
                    self.howToPlayButtonIcon.image = image
                }
            }).disposed(by: disposeBag)
        
        let _ = viewModel.transit
            .subscribe(onNext: { [weak self] type in
                guard let self = self else {return}
                switch type {
                case .start:
                    CameraAuthModel.checkCameraAuthorization(vc: self)
                    self.presentGameVC()
                    
                case .settings:
                    let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                    let navi = UINavigationController(rootViewController: vc)
                    navi.setNavigationBarHidden(true, animated: false)
                    self.presentPanModal(navi)

                case .howToPlay:
                    let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
                    vc.isBlurEffectEnabled = false
                    let navi = UINavigationController(rootViewController: vc)
                    navi.setNavigationBarHidden(true, animated: false)
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
    
}
