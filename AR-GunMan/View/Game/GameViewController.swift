//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/15.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import FSPagerView
import PanModal
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    
    //MARK: - Properties
    let viewModel = GameViewModel()
    let sceneManager = GameSceneManager()
    let disposeBag = DisposeBag()

    @IBOutlet weak var bulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - input
        //CoreMotionで特定の加速度とジャイロイベントを検知した時にVMに通知
        CoreMotionUtil.getAccelerometer {
            self.viewModel.userShookDevide.onNext(Void())
        }
        CoreMotionUtil.getGyro {
            self.viewModel.userRotateDevice.onNext(Void())
        } secretEvent: {
            self.viewModel.userRotateDevice20Times.onNext(Void())
        }
        
        let _ = sceneManager.targetHit
            .bind(to: viewModel.targetHit)
            .disposed(by: disposeBag)
                

        //MARK: - output
        let _ = viewModel.sightImage
            .bind(to: sightImageView.rx.image)
            .disposed(by: disposeBag)
        
        let _ = viewModel.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        let _ = viewModel.timeCountString
            .bind(to: timeCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        let _ = viewModel.checkPlayerAnimation
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sceneManager.handlePlayerAnimation()
            }).disposed(by: disposeBag)
        
        let _ = viewModel.showWeapon
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sceneManager.showWeapon(element)
            }).disposed(by: disposeBag)
        
        let _ = viewModel.fireWeapon
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.sceneManager.fireWeapon()
            }).disposed(by: disposeBag)
        
        let _ = viewModel.excuteSecretEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.sceneManager.changeTargetsToTaimeisan()
            }).disposed(by: disposeBag)

        let _ = viewModel.transitResultVC
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "GameResultViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GameResultViewController") as! GameResultViewController
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        
        //MARK: - other
        addSceneView()
        // - 初回のみチュートリアルを表示するのでチェック
        checkTutorialSeenStatus()
        // - 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
        
        let _ = switchWeaponButton.rx.tap
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "SwitchWeaponViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SwitchWeaponViewController") as! SwitchWeaponViewController
                vc.viewModel = self.viewModel
                self.presentPanModal(vc)
            }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SceneViewSettingUtil.startSession(sceneManager.sceneView)
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        SceneViewSettingUtil.pauseSession(sceneManager.sceneView)
    }
    
    private func addSceneView() {
        sceneManager.sceneView.frame = view.frame
        view.insertSubview(sceneManager.sceneView, at: 0)
    }
    
    private func checkTutorialSeenStatus() {
        if UserDefaultsUtil.isTutorialAlreadySeen() {
            viewModel.tutorialEnded.onNext(Void())
            
        }else {
            let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
            vc.delegate = self
            self.presentPanModal(vc)
        }
    }
}

extension GameViewController: TutorialVCDelegate {
    func tutorialEnded() {
        viewModel.tutorialEnded.onNext(Void())
    }
}
