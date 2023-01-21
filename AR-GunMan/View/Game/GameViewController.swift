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
    var viewModel: GameViewModel2!
    let sceneManager = GameSceneManager()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var bulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - input
        let vmInput = GameViewModel2
            .Input(viewDidAppear: rx.viewDidAppear,
                   targetHit: sceneManager.targetHit,
                   switchWeaponButtonTapped: switchWeaponButton.rx.tap.asObservable())
        
        let vmDependency = GameViewModel2
            .Dependency(tutorialSeenChecker: TutorialSeenChecker(),
                        motionDetector: MotionDetector(),
                        currentWeapon: CurrentWeapon(type: .pistol),
                        timeCounter: TimeCounter(),
                        scoreCounter: ScoreCounter())
        
        viewModel = GameViewModel2(input: vmInput, dependency: vmDependency)
        
        //MARK: - output
        viewModel.sightImage
            .bind(to: sightImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.sightImageColor
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sightImageView.tintColor = element
            }).disposed(by: disposeBag)
        
        viewModel.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.timeCountText
            .bind(to: timeCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.weaponTypeChanged
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sceneManager.showWeapon(element)
            }).disposed(by: disposeBag)
        
        viewModel.weaponFired
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                self.sceneManager.fireWeapon()
            }).disposed(by: disposeBag)
        
        viewModel.showTutorialView
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
                vc.vmDependency = .init(transitionType: .gamePage,
                                        delegate: element)
                self.presentPanModal(vc)
            }).disposed(by: disposeBag)
        
        viewModel.showSwitchWeaponView
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "SwitchWeaponViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SwitchWeaponViewController") as! SwitchWeaponViewController
                //                vc.viewModel = self.viewModel
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.showResultView
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "GameResultViewController", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GameResultViewController") as! GameResultViewController
                vc.totalScore = element
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        //MARK: - other
        addSceneView()
        // - 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
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
}
