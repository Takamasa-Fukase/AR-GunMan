//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/5/24.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    var viewModel: GameViewModel!
    var arContentController: ARContentController!
    var deviceMotionController: DeviceMotionController!
    private let disposeBag = DisposeBag()
    
    @IBOutlet private weak var bulletsCountImageView: UIImageView!
    @IBOutlet private weak var sightImageView: UIImageView!
    @IBOutlet private weak var timeCountLabel: UILabel!
    @IBOutlet private weak var weaponChangeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        let input = GameViewModel.Input(
            inputFromView: GameViewModel.Input.InputFromView(
                viewDidLoad: .just(()),
                viewWillAppear: rx.viewWillAppear,
                viewDidAppear: rx.viewDidAppear,
                viewWillDisappear: rx.viewWillDisappear,
                weaponChangeButtonTapped: weaponChangeButton.rx.tap.asObservable()
            ),
            inputFromARContent: GameViewModel.Input.InputFromARContent(
                rendererUpdated: arContentController.rendererUpdated,
                collisionOccurred: arContentController.collisionOccurred
            ),
            inputFromDeviceMotion: GameViewModel.Input.InputFromDeviceMotion(
                accelerationUpdated: deviceMotionController.accelerationUpdated,
                gyroUpdated: deviceMotionController.gyroUpdated
            )
        )

        let output = viewModel.transform(input: input)

        subscribeViewModelActions(output.viewModelAction)
        bindOutputToViewComponents(output.outputToView)
        bindOutputToARContentController(output.outputToARContent)
        bindOutputToDeviceMotionController(output.outputToDeviceMotion)
    }

    private func setupUI() {
        // MEMO: to prevent time count text looks shaking horizontally rapidly.
        timeCountLabel.font = timeCountLabel.font.monospacedDigitFont
    }
    
    private func subscribeViewModelActions(
        _ viewModelAction: GameViewModel.Output.ViewModelAction
    ) {
        disposeBag.insert {
            viewModelAction.pistolSetSoundPlayed.subscribe()
            viewModelAction.startWhistleSoundPlayed.subscribe()
            viewModelAction.firingSoundPlayed.subscribe()
            viewModelAction.noBulletsSoundPlayed.subscribe()
            viewModelAction.reloadingSoundPlayed.subscribe()
            viewModelAction.targetHitSoundPlayed.subscribe()
            viewModelAction.targetsAppearanceChangingSoundPlayed.subscribe()
            viewModelAction.weaponChangingSoundPlayed.subscribe()
            viewModelAction.endWhistleSoundPlayed.subscribe()
            viewModelAction.rankingAppearSoundPlayed.subscribe()
            viewModelAction.weaponTypeChanged.subscribe()
            viewModelAction.weaponReloadingFlagChanged.subscribe()
            viewModelAction.weaponReloadingFlagChangedForNewWeapon.subscribe()
            viewModelAction.bulletsCountDecremented.subscribe()
            viewModelAction.bulletsCountRefilled.subscribe()
            viewModelAction.bulletsCountRefilledForNewWeapon.subscribe()
            viewModelAction.scoreUpdated.subscribe()
            viewModelAction.reloadingMotionDetectedCountUpdated.subscribe()
            viewModelAction.tutorialViewShowed.subscribe()
            viewModelAction.weaponChangeViewShowed.subscribe()
            viewModelAction.weaponChangeViewDismissedOnTimerDisposal.subscribe()
            viewModelAction.resultViewShowed.subscribe()
            viewModelAction.weaponFireProcessCompleted.subscribe()
            viewModelAction.weaponReloadProcessCompleted.subscribe()
            viewModelAction.weaponChangeProcessCompleted.subscribe()
            viewModelAction.timerDisposed.subscribe()
        }
    }
    
    private func bindOutputToViewComponents(
        _ outputToView: GameViewModel.Output.OutputToView
    ) {
        disposeBag.insert {
            outputToView.sightImageName
                .map({ UIImage(named: $0) })
                .bind(to: sightImageView.rx.image)
            outputToView.sightImageColorHexCode
                .map({ UIColor(hexString: $0) })
                .bind(to: sightImageView.rx.tintColor)
            outputToView.timeCountText
                .bind(to: timeCountLabel.rx.text)
            outputToView.bulletsCountImageName
                .map({ UIImage(named: $0) })
                .bind(to: bulletsCountImageView.rx.image)
            outputToView.isWeaponChangeButtonEnabled
                .bind(to: weaponChangeButton.rx.isEnabled)
        }
    }
    
    private func bindOutputToARContentController(
        _ outputToARContent: GameViewModel.Output.OutputToARContent
    ) {
        disposeBag.insert {
            outputToARContent.setupSceneView
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    let sceneView = self.arContentController.setupSceneView(with: self.view.frame)
                    self.view.insertSubview(sceneView, at: 0)
                })
            outputToARContent.renderAllTargets
                .subscribe(onNext: { [weak self] count in
                    guard let self = self else { return }
                    self.arContentController.showTargets(count: count)
                })
            outputToARContent.startSceneSession
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.arContentController.startSession()
                })
            outputToARContent.pauseSceneSession
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.arContentController.pauseSession()
                })
            outputToARContent.renderSelectedWeapon
                .subscribe(onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.arContentController.showWeapon(type)
                })
            outputToARContent.renderWeaponFiring
                .subscribe(onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.arContentController.fireWeapon(type)
                })
            outputToARContent.renderTargetsAppearanceChanging
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.arContentController.changeTargetsToTaimeisan()
                })
            outputToARContent.moveWeaponToFPSPosition
                .subscribe(onNext: { [weak self] type in
                    guard let self = self else { return }
                    self.arContentController.moveWeaponToFPSPosition(currentWeapon: type)
                })
            outputToARContent.removeContactedTargetAndBullet
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.arContentController.removeContactedTargetAndBullet(targetId: $0.targetId, bulletId: $0.bulletId)
                })
            outputToARContent.renderTargetHitParticleToContactPoint
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.arContentController.showTargetHitParticleToContactPoint(weaponType: $0.weaponType, contactPoint: $0.contactPoint)
                })
        }
    }
    
    private func bindOutputToDeviceMotionController(
        _ OutputToDeviceMotion: GameViewModel.Output.OutputToDeviceMotion
    ) {
        disposeBag.insert {
            OutputToDeviceMotion.startMotionDetection
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.deviceMotionController.startUpdate()
                })
            OutputToDeviceMotion.stopMotionDetection
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.deviceMotionController.stopUpdate()
                })
        }
    }
}
