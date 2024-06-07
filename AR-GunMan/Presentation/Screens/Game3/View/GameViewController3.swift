//
//  GameViewController3.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/5/24.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController3: UIViewController {
    var viewModel: GameViewModel3!
    // TODO: change class name to "ARContentController"
    var gameSceneController: GameSceneController!
    // TODO: change class name to "DeviceMotionController"
    var coreMotionController: CoreMotionController!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var bulletsCountImageView: UIImageView!
    @IBOutlet private weak var sightImageView: UIImageView!
    @IBOutlet private weak var timeCountLabel: UILabel!
    @IBOutlet private weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        let input = GameViewModel3.Input(
            inputFromView: GameViewModel3.Input.InputFromView(
                viewDidLoad: .just(()),
                viewWillAppear: rx.viewWillAppear,
                viewDidAppear: rx.viewDidAppear,
                viewWillDisappear: rx.viewWillDisappear,
                weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
            ),
            inputFromGameScene: GameViewModel3.Input.InputFromGameScene(
                rendererUpdated: gameSceneController.rendererUpdated,
                targetHit: gameSceneController.targetHit
            ),
            inputFromCoreMotion: GameViewModel3.Input.InputFromCoreMotion(
                accelerationUpdated: coreMotionController.accelerationUpdated,
                gyroUpdated: coreMotionController.gyroUpdated
            )
        )

        let output = viewModel.transform(input: input)

        subscribeViewModelActions(output.viewModelAction)
        bindOutputToViewComponents(output.outputToView)
        bindOutputToGameSceneController(output.outputToGameScene)
        bindOutputToCoreMotionController(output.outputToDeviceMotion)
    }

    private func setupUI() {
        // MEMO: to prevent time count text looks shaking horizontally rapidly.
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
    }
    
    private func subscribeViewModelActions(
        _ viewModelAction: GameViewModel3.Output.ViewModelAction
    ) {
        disposeBag.insert {
            viewModelAction.noBulletsSoundPlayed.subscribe()
            viewModelAction.bulletsCountDecremented.subscribe()
            viewModelAction.firingSoundPlayed.subscribe()
            viewModelAction.weaponFireProcessCompleted.subscribe()
            viewModelAction.bulletsCountRefilled.subscribe()
            viewModelAction.weaponReloadingFlagChanged.subscribe()
            viewModelAction.reloadingSoundPlayed.subscribe()
            viewModelAction.weaponReloadProcessCompleted.subscribe()
            viewModelAction.weaponTypeChanged.subscribe()
            viewModelAction.weaponChangingSoundPlayed.subscribe()
            viewModelAction.bulletsCountRefilledForNewWeapon.subscribe()
            viewModelAction.weaponReloadingFlagChangedForNewWeapon.subscribe()
            viewModelAction.weaponChangeProcessCompleted.subscribe()
            viewModelAction.targetHitSoundPlayed.subscribe()
            viewModelAction.scoreUpdated.subscribe()
            viewModelAction.tutorialViewShowed.subscribe()
            viewModelAction.pistolSetSoundPlayed.subscribe()
            viewModelAction.startWhistleSoundPlayed.subscribe()
            viewModelAction.endWhistleSoundPlayed.subscribe()
            viewModelAction.timerDisposed.subscribe()
            viewModelAction.weaponChangeViewShowed.subscribe()
            viewModelAction.weaponChangeViewDismissed.subscribe()
            viewModelAction.rankingAppearSoundPlayed.subscribe()
            viewModelAction.resultViewShowed.subscribe()
            viewModelAction.reloadingMotionDetectedCountUpdated.subscribe()
            viewModelAction.targetsAppearanceChangingSoundPlayed.subscribe()
        }
    }
    
    private func bindOutputToViewComponents(
        _ outputToView: GameViewModel3.Output.OutputToView
    ) {
        disposeBag.insert {
            outputToView.sightImage
                .bind(to: sightImageView.rx.image)
            outputToView.sightImageColor
                .bind(to: sightImageView.rx.tintColor)
            outputToView.timeCountText
                .bind(to: timeCountLabel.rx.text)
            outputToView.bulletsCountImage
                .bind(to: bulletsCountImageView.rx.image)
            outputToView.isWeaponChangeButtonEnabled
                .bind(to: switchWeaponButton.rx.isEnabled)
        }
    }
    
    private func bindOutputToGameSceneController(
        _ outputToGameScene: GameViewModel3.Output.OutputToGameScene
    ) {
        disposeBag.insert {
            outputToGameScene.setupSceneView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    let sceneView = self.gameSceneController.setupSceneView(with: self.view.frame)
                    self.view.insertSubview(sceneView, at: 0)
                })
            outputToGameScene.renderAllTargets
                .subscribe(onNext: { [weak self] count in
                    guard let self = self else { return }
                    self.gameSceneController.showTargets(count: count)
                })
            outputToGameScene.startSceneSession
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.gameSceneController.startSession()
                })
            outputToGameScene.pauseSceneSession
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.gameSceneController.pauseSession()
                })
            outputToGameScene.renderSelectedWeapon
                .subscribe(onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.gameSceneController.showWeapon(type)
                })
            outputToGameScene.renderWeaponFiring
                .subscribe(onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.gameSceneController.fireWeapon(type)
                })
            outputToGameScene.renderTargetsAppearanceChanging
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.gameSceneController.changeTargetsToTaimeisan()
                })
            outputToGameScene.moveWeaponToFPSPosition
                .subscribe(onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.gameSceneController.moveWeaponToFPSPosition(currentWeapon: type)
                })
        }
    }
    
    private func bindOutputToCoreMotionController(
        _ OutputToDeviceMotion: GameViewModel3.Output.OutputToDeviceMotion
    ) {
        disposeBag.insert {
            OutputToDeviceMotion.startMotionDetection
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.coreMotionController.startUpdate()
                })
            OutputToDeviceMotion.stopMotionDetection
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.coreMotionController.stopUpdate()
                })
        }
    }
}
