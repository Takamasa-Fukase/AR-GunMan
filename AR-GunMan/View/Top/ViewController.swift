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

class ViewController: UIViewController {
    
    //MARK: - Properties
    let viewModel = TopViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var rankingButton: UIButton!
    @IBOutlet weak var howToPlayButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var startButtonIcon: UIImageView!
    @IBOutlet weak var rankingButtonIcon: UIImageView!
    @IBOutlet weak var howToPlayButtonIcon: UIImageView!
    
    //MARK: - Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
               
        if replayFlag {
            presentGameVC(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButtonIcon.image = TopConst.targetIcon
        rankingButtonIcon.image = TopConst.targetIcon
        howToPlayButtonIcon.image = TopConst.targetIcon
        
        //input
        let _ = startButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.start)
            }).disposed(by: disposeBag)
        
        let _ = rankingButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.ranking)
            }).disposed(by: disposeBag)
        
        let _ = howToPlayButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.howToPlay)
            }).disposed(by: disposeBag)
        
        let _ = settingsButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.viewModel.buttonTapped.onNext(.settings)
            }).disposed(by: disposeBag)
        
        //output
        let _ = viewModel.isShotButtonIcon
            .subscribe(onNext: { [weak self] (type, bool) in
                guard let self = self else {return}
                let image = bool ? TopConst.bulletsHoleIcon : TopConst.targetIcon
                switch type {
                case .start:
                    self.startButtonIcon.image = image
                case .ranking:
                    self.rankingButtonIcon.image = image
                case .howToPlay:
                    self.howToPlayButtonIcon.image = image
                default:
                    break
                }
            }).disposed(by: disposeBag)
        
        let _ = viewModel.transit
            .subscribe(onNext: { [weak self] type in
                guard let self = self else {return}
                switch type {
                case .start:
                    CameraAuthUtil.checkCameraAuthorization(vc: self)
                    self.presentGameVC()
                    
                case .ranking:
                    self.presentRankingVC()
                    
                case .howToPlay:
                    self.presentHowToPlayVC()
                    
                case .settings:
                    self.presentSettingsVC()
                }
            }).disposed(by: disposeBag)
    }
    
    func presentGameVC(animated: Bool = true) {
        startButtonIcon.image = TopConst.targetIcon
        
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: animated)
    }
    
    func presentRankingVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "WorldRankingViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! WorldRankingViewController
        self.presentPanModal(vc)
    }
    
    func presentHowToPlayVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
        vc.transitionType = .topPage
        self.presentPanModal(vc)
    }
    
    func presentSettingsVC() {
        let storyboard: UIStoryboard = UIStoryboard(name: "SettingsViewController", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        self.presentPanModal(vc)
    }
}
