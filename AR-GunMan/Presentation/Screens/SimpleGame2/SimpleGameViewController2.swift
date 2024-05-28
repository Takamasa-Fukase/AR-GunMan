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
    
    private let firingMotionDetected = PublishRelay<Void>()
    private let reloadingMotionDetected = PublishRelay<Void>()
    
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
                firingMotionDetected: firingMotionDetected.asObservable(),
                reloadingMotionDetected: reloadingMotionDetected.asObservable()
            )
        )

        let output = viewModel.transform(input: input)
        
        output.outputToView.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.outputToGameScene.renderSelectedWeapon
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.gameSceneController.showWeapon(type)
            }).disposed(by: disposeBag)
        
        output.outputToGameScene.renderWeaponFiring
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.gameSceneController.fireWeapon(type)
            }).disposed(by: disposeBag)
        
        output.viewModelAction.weaponSelected
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.weaponFired
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.bulletsCountRefilled
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.weaponReloadingFlagChanged
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.reloadingSoundPlayed
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.weaponReloaded
            .subscribe()
            .disposed(by: disposeBag)
        
        // other
        gameSceneController.rendererUpdated
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.gameSceneController.moveWeaponToFPSPosition(currentWeapon: .pistol)
            }).disposed(by: disposeBag)
        
        CoreMotionStreamFilter
            .filterFiringMotionStream(
                accelerationStream: coreMotionController.accelerationUpdated,
                gyroStream: coreMotionController.gyroUpdated
            )
            .bind(to: firingMotionDetected)
            .disposed(by: disposeBag)
        
        CoreMotionStreamFilter
            .filterReloadingMotionStream(
                gyroStream: coreMotionController.gyroUpdated
            )
            .bind(to: reloadingMotionDetected)
            .disposed(by: disposeBag)
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
}
