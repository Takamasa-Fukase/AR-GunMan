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
    // TODO: 命名をARContentControllerとか抽象的な命名にして、実装詳細を意識しない様にしたい
    var gameSceneController: GameSceneController!
    // TODO: 命名をDeviceMotionControllerとか抽象的な命名にして、実装詳細を意識しない様にしたい
    var coreMotionController: CoreMotionController!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var bulletsCountImageView: UIImageView!
    @IBOutlet private weak var sightImageView: UIImageView!
    @IBOutlet private weak var timeCountLabel: UILabel!
    @IBOutlet private weak var switchWeaponButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        let sceneView = gameSceneController.setupSceneView(with: view.frame)
        view.insertSubview(sceneView, at: 0)
        gameSceneController.showTargets(count: 50)
        gameSceneController.showWeapon(.pistol)

        let input = GameViewModel3.Input(
            inputFromView: GameViewModel3.Input.InputFromView(
                viewDidAppear: rx.viewDidAppear,
                weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
            ),
            inputFromGameScene: GameViewModel3.Input.InputFromGameScene(
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
        
        // other
        gameSceneController.rendererUpdated
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.gameSceneController.moveWeaponToFPSPosition(currentWeapon: .pistol)
            }).disposed(by: disposeBag)
    }

    private func setupUI() {
        // 等幅フォントにして高速で動くタイムカウントの横振れを防止
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameSceneController.startSession()
//        self.coreMotionController.startUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.gameSceneController.pauseSession()
        self.coreMotionController.stopUpdate()
    }
    
    private func subscribeViewModelActions(
        _ viewModelAction: GameViewModel3.Output.ViewModelAction
    ) {
        disposeBag.insert {
            viewModelAction.noBulletsSoundPlayed.subscribe()
            viewModelAction.bulletsCountDecremented.subscribe()
            viewModelAction.firingSoundPlayed.subscribe()
            viewModelAction.weaponFired.subscribe()
            viewModelAction.bulletsCountRefilled.subscribe()
            viewModelAction.weaponReloadingFlagChanged.subscribe()
            viewModelAction.reloadingSoundPlayed.subscribe()
            viewModelAction.weaponReloaded.subscribe()
            viewModelAction.weaponTypeChanged.subscribe()
            viewModelAction.weaponChangingSoundPlayed.subscribe()
            viewModelAction.bulletsCountRefilledForNewWeapon.subscribe()
            viewModelAction.weaponReloadingFlagChangedForNewWeapon.subscribe()
            viewModelAction.weaponChanged.subscribe()
            viewModelAction.targetHitSoundPlayed.subscribe()
            viewModelAction.scoreUpdated.subscribe()
            viewModelAction.tutorialViewShowed.subscribe()
            viewModelAction.pistolSetSoundPlayed.subscribe()
            viewModelAction.startWhistleSoundPlayed.subscribe()
            viewModelAction.endWhistleSoundPlayed.subscribe()
            viewModelAction.timerDisposed.subscribe()
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
        }
    }
    
    private func bindOutputToGameSceneController(
        _ outputToGameScene: GameViewModel3.Output.OutputToGameScene
    ) {
        disposeBag.insert {
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
        }
    }
}
