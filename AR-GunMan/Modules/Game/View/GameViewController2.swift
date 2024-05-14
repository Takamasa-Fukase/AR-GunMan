//
//  GameViewController2.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/13.
//

import UIKit
import RxSwift
import RxCocoa

final class GameViewController2: UIViewController {
    var viewModel: GameViewModel2!
    var gameSceneController: GameSceneController!
    var coreMotionController: CoreMotionController!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var bulletsCountImageView: UIImageView!
    @IBOutlet private weak var sightImageView: UIImageView!
    @IBOutlet private weak var timeCountLabel: UILabel!
    @IBOutlet private weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        let input = GameViewModel2.Input(
            inputFromView: GameViewModel2.Input.InputFromView(
                viewDidLoad: Observable.just(Void()),
                viewWillAppear: rx.viewWillAppear,
                viewDidAppear: rx.viewDidAppear,
                viewWillDisappear: rx.viewWillDisappear,
                weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
            ),
            inputFromGameScene: GameViewModel2.Input.InputFromGameScene(
                rendererUpdated: gameSceneController.rendererUpdated,
                targetHit: gameSceneController.targetHit
            ),
            inputFromCoreMotion: GameViewModel2.Input.InputFromCoreMotion(
                accelerationUpdated: coreMotionController.accelerationUpdated,
                gyroUpdated: coreMotionController.gyroUpdated
            )
        )

        let output = viewModel.transform(input: input)
        
        bindOutputToViewComponents(output.outputToView)
        bindOutputToGameSceneController(output.outputToGameScene)
        bindOutputToCoreMotionController(output.outputToCoreMotion)
    }
    
    private func setupUI() {
        // - 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
    }
    
    private func bindOutputToViewComponents(
        _ output: GameViewModel2.Output.OutputToView
    ) {        
        output.sightImage
            .bind(to: sightImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.sightImageColor
            .subscribe(onNext: { [weak self] element in
                guard let self = self else {return}
                self.sightImageView.tintColor = element
            }).disposed(by: disposeBag)
        
        output.timeCountText
            .bind(to: timeCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)

        output.showTutorialView
            .subscribe()
            .disposed(by: disposeBag)
        
        output.showWeaponChangeView
            .subscribe()
            .disposed(by: disposeBag)
        
        output.dismissWeaponChangeView
            .subscribe()
            .disposed(by: disposeBag)
        
        output.showResultView
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func bindOutputToGameSceneController(
        _ output: GameViewModel2.Output.OutputToGameScene
    ) {
        output.setupSceneViewAndNodes
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.gameSceneController.setupSceneViewAndNodes()
            }).disposed(by: disposeBag)
        
        output.showTargets
            .subscribe(onNext: { [weak self] count in
                guard let self = self else { return }
                self.gameSceneController.showTargets(count: count)
            }).disposed(by: disposeBag)
        
        output.startSession
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.gameSceneController.startSession()
            }).disposed(by: disposeBag)
        
        output.pauseSession
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.gameSceneController.pauseSession()
            }).disposed(by: disposeBag)
        
        output.showWeapon
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.gameSceneController.showWeapon(type)
            }).disposed(by: disposeBag)
        
        output.fireWeapon
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.gameSceneController.fireWeapon(type)
            }).disposed(by: disposeBag)
        
        output.executeSecretEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.gameSceneController.changeTargetsToTaimeisan()
            }).disposed(by: disposeBag)
        
        output.moveWeaponToFPSPosition
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.gameSceneController.moveWeaponToFPSPosition(currentWeapon: type)
            }).disposed(by: disposeBag)
    }
    
    private func bindOutputToCoreMotionController(
        _ output: GameViewModel2.Output.OutputToCoreMotion
    ) {
        output.startUpdate
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.coreMotionController.startUpdate()
            }).disposed(by: disposeBag)
        
        output.stopUpdate
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.coreMotionController.stopUpdate()
            }).disposed(by: disposeBag)
    }
}
