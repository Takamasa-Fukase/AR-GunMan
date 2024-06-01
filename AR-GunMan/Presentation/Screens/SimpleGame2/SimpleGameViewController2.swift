//
//  SimpleGameViewController2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/5/24.
//

import UIKit
import RxSwift
import RxCocoa

class SimpleGameViewController2: UIViewController {
    var viewModel: SimpleGameViewModel2!
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
        
        let sceneView = gameSceneController.setupSceneView(with: view.frame)
        view.insertSubview(sceneView, at: 0)
        gameSceneController.showTargets(count: 50)
        gameSceneController.showWeapon(.pistol)

        let input = SimpleGameViewModel2.Input(
            inputFromView: SimpleGameViewModel2.Input.InputFromView(
                weaponChangeButtonTapped: switchWeaponButton.rx.tap.asObservable()
            ),
            inputFromGameScene: SimpleGameViewModel2.Input.InputFromGameScene(
                targetHit: gameSceneController.targetHit
            ),
            inputFromCoreMotion: SimpleGameViewModel2.Input.InputFromCoreMotion(
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
        self.coreMotionController.startUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.gameSceneController.pauseSession()
        self.coreMotionController.stopUpdate()
    }
    
    private func subscribeViewModelActions(
        _ viewModelAction: SimpleGameViewModel2.Output.ViewModelAction
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
        }
    }
    
    private func bindOutputToViewComponents(
        _ outputToView: SimpleGameViewModel2.Output.OutputToView
    ) {
        disposeBag.insert {
            outputToView.bulletsCountImage
                .bind(to: bulletsCountImageView.rx.image)
        }
    }
    
    private func bindOutputToGameSceneController(
        _ outputToGameScene: SimpleGameViewModel2.Output.OutputToGameScene
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
}
