//
//  SimpleGameViewController.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/15.
//

import UIKit
import ARKit
import RxSwift
import RxCocoa

class SimpleGameViewController: UIViewController {
    var viewModel: SimpleGameViewModel!
    var gameSceneController: GameSceneController!
    var coreMotionController: CoreMotionController!
    private let disposeBag = DisposeBag()
    
    private let firingMotionDetected = PublishRelay<Void>()
    private let reloadingMotionDetected = PublishRelay<Void>()
    
    @IBOutlet private weak var bulletsCountImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sceneView = gameSceneController.setupSceneView(with: view.frame)
        view.insertSubview(sceneView, at: 0)
        gameSceneController.showTargets(count: 50)
        gameSceneController.showWeapon(.pistol)
        
        let input = SimpleGameViewModel.Input(
            inputFromGameScene: SimpleGameViewModel.Input.InputFromGameScene(
                targetHit: gameSceneController.targetHit
            ),
            inputFromCoreMotion: SimpleGameViewModel.Input.InputFromCoreMotion(
                firingMotionDetected: firingMotionDetected.asObservable(),
                reloadingMotionDetected: reloadingMotionDetected.asObservable()
            )
        )

        let output = viewModel.transform(input: input)
        
        output.outputToView.bulletsCountImage
            .bind(to: bulletsCountImageView.rx.image)
            .disposed(by: disposeBag)
        
        output.outputToGameScene.renderWeaponFiring
            .subscribe(onNext: { [weak self] type in
                guard let self = self else { return }
                self.gameSceneController.fireWeapon(type)
            }).disposed(by: disposeBag)
        
        output.viewModelAction.fireWeapon
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.reloadWeapon
            .subscribe()
            .disposed(by: disposeBag)
        
        output.viewModelAction.addScore
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