//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/08/15.
//  Copyright © 2020 fukase. All rights reserved.
//

import UIKit
import ARKit
import FSPagerView
import PanModal
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
//    var viewModel: GameViewModel!
    var viewModel = GameViewModel2()
    let disposeBag = DisposeBag()
    let sceneView = ARSCNView()

    @IBOutlet weak var bulletsCountImageView: UIImageView!
    @IBOutlet weak var sightImageView: UIImageView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        //MARK: - input
        let currentWeapon = CurrentWeapon(type: .pistol)
        let timeCounter = TimeCounter()
        
        let input: GameViewModel2.Input = .init(
            viewDidAppear: rx.viewDidAppear,
            weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
        )
        let sceneManager = GameSceneManager(sceneView: sceneView)
        
        let output = viewModel.transform(
            input: input,
            sceneManager: sceneManager,
            disposeBag: disposeBag
        )
        
        //MARK: - output
        output.sightImage
            .bind(to: sightImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.sightImageColor
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sightImageView.tintColor = element
            }).disposed(by: disposeBag)
        
        output.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.timeCountText
            .bind(to: timeCountLabel.rx.text)
            .disposed(by: disposeBag)

        output.showTutorialView
            .subscribe(onNext: { [weak self] delegate in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
                vc.vmDependency = .init(transitionType: .gamePage,
                                        delegate: delegate)
                self.presentPanModal(vc)
            }).disposed(by: disposeBag)
        
        output.showWeaponChangeView
            .subscribe(onNext: { [weak self] delegate in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "WeaponChangeViewController", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! WeaponChangeViewController
                vc.vmDependency = .init(delegate: delegate)
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
        
        output.dismissWeaponChangeView
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {return}
                print("dismissWeaponChangeView")
                self.presentedViewController?.dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        output.showResultView
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                let storyboard: UIStoryboard = UIStoryboard(name: "ResultViewController", bundle: nil)
                let vc = storyboard.instantiateInitialViewController() as! ResultViewController
                vc.vmDependency = .init(rankingRepository: RankingRepository(),
                                        totalScore: element)
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUI()
//
//        //MARK: - input
//        let currentWeapon = CurrentWeapon(type: .pistol)
//        let timeCounter = TimeCounter()
//        
//        viewModel = GameViewModel(
//            input: .init(
//                viewDidAppear: rx.viewDidAppear,
//                weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
//            ),
//            dependency: .init(
//                tutorialSeenChecker: TutorialSeenChecker(),
//                motionDetector: MotionDetector(),
//                currentWeapon: currentWeapon,
//                timeCounter: timeCounter,
//                scoreCounter: ScoreCounter(),
//                sceneManager: GameSceneManager(sceneView: sceneView)
//            )
//        )
//        
//        //MARK: - output
//        viewModel.sightImage
//            .bind(to: sightImageView.rx.image)
//            .disposed(by: disposeBag)
//        
//        viewModel.sightImageColor
//            .subscribe(onNext: { [weak self] element in
//                guard let self = self else {return}
//                self.sightImageView.tintColor = element
//            }).disposed(by: disposeBag)
//        
//        viewModel.bulletsCountImage
//            .bind(to: bulletsCountImageView.rx.image)
//            .disposed(by: disposeBag)
//        
//        viewModel.timeCountText
//            .bind(to: timeCountLabel.rx.text)
//            .disposed(by: disposeBag)
//
//        viewModel.showTutorialView
//            .subscribe(onNext: { [weak self] element in
//                guard let self = self else {return}
//                let storyboard: UIStoryboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
//                let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
//                vc.vmDependency = .init(transitionType: .gamePage,
//                                        delegate: element)
//                self.presentPanModal(vc)
//            }).disposed(by: disposeBag)
//        
//        viewModel.showWeaponChangeView
//            .subscribe(onNext: { [weak self] element in
//                guard let self = self else {return}
//                let storyboard: UIStoryboard = UIStoryboard(name: "WeaponChangeViewController", bundle: nil)
//                let vc = storyboard.instantiateInitialViewController() as! WeaponChangeViewController
//                vc.vmDependency = .init(
//                    currentWeapon: currentWeapon,
//                    timeCounter: timeCounter
//                )
//                self.present(vc, animated: true)
//            }).disposed(by: disposeBag)
//        
//        viewModel.showResultView
//            .subscribe(onNext: { [weak self] element in
//                guard let self = self else {return}
//                let storyboard: UIStoryboard = UIStoryboard(name: "ResultViewController", bundle: nil)
//                let vc = storyboard.instantiateInitialViewController() as! ResultViewController
//                vc.vmDependency = .init(rankingRepository: RankingRepository(),
//                                        totalScore: element)
//                self.present(vc, animated: true)
//            }).disposed(by: disposeBag)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SceneViewSettingUtil.startSession(sceneView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SceneViewSettingUtil.pauseSession(sceneView)
    }

    private func setupUI() {
        // - 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
        sceneView.frame = view.frame
        view.insertSubview(sceneView, at: 0)
    }
}
