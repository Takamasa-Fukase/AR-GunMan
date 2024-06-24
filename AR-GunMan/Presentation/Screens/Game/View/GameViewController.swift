//
//  GameViewController.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 23/6/24.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    var presenter: GamePresenterInterface!
    var arContentController: ARContentController!
    var deviceMotionController: DeviceMotionController!
    private let disposeBag = DisposeBag()
    private let contentView = GameContentView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
        bind()
    }
    
    private func setView() {
        view.addSubview(contentView)
        view.addConstraints(for: contentView)
        view.backgroundColor = .systemBackground
    }
    
    private func bind() {
        let input = GameControllerInput(
            inputFromViewController: GameControllerInput.InputFromViewController(
                viewDidLoad: .just(()),
                viewWillAppear: rx.viewWillAppear,
                viewDidAppear: rx.viewDidAppear,
                viewWillDisappear: rx.viewWillDisappear,
                weaponChangeButtonTapped: contentView.weaponChangeButton.rx.tap.asObservable()
            ),
            inputFromARContent: GameControllerInput.InputFromARContent(
                rendererUpdated: arContentController.rendererUpdated,
                collisionOccurred: arContentController.collisionOccurred
            ),
            inputFromDeviceMotion: GameControllerInput.InputFromDeviceMotion(
                accelerationUpdated: deviceMotionController.accelerationUpdated,
                gyroUpdated: deviceMotionController.gyroUpdated
            )
        )
        let viewModel = presenter.transform(input: input)
        bindOutputToViewComponents(viewModel.outputToView)
        bindOutputToARContentController(viewModel.outputToARContent)
        bindOutputToDeviceMotionController(viewModel.outputToDeviceMotion)
    }
    
    private func bindOutputToViewComponents(
        _ outputToView: GameViewModel.OutputToView
    ) {
        disposeBag.insert {
            outputToView.sightImageName
                .map({ UIImage(named: $0) })
                .bind(to: contentView.sightImageView.rx.image)
            outputToView.sightImageColorHexCode
                .map({ UIColor(hexString: $0) })
                .bind(to: contentView.sightImageView.rx.tintColor)
            outputToView.timeCountText
                .bind(to: contentView.timeCountLabel.rx.text)
            outputToView.bulletsCountImageName
                .map({ UIImage(named: $0) })
                .bind(to: contentView.bulletsCountImageView.rx.image)
            outputToView.isWeaponChangeButtonEnabled
                .bind(to: contentView.weaponChangeButton.rx.isEnabled)
        }
    }
    
    private func bindOutputToARContentController(
        _ outputToARContent: GameViewModel.OutputToARContent
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
        _ outputToDeviceMotion: GameViewModel.OutputToDeviceMotion
    ) {
        disposeBag.insert {
            outputToDeviceMotion.startMotionDetection
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.deviceMotionController.startUpdate()
                })
            outputToDeviceMotion.stopMotionDetection
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.deviceMotionController.stopUpdate()
                })
        }
    }
}
