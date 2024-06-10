//
//  GameNavigator.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/5/24.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

protocol GameNavigatorInterface {
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>)
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>)
    func dismissWeaponChangeView()
    func showResultView(score: Double)
}

final class GameNavigator: GameNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: GameViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        
        let navigator = GameNavigator(viewController: vc)
        let useCase = GameUseCase(
            tutorialRepository: TutorialRepository(),
            timerRepository: TimerRepository()
        )
        let viewModel = GameViewModel(
            useCase: useCase,
            navigator: navigator,
            tutorialSeenStatusHandler: TutorialSeenStatusHandler(gameUseCase: useCase),
            gameStartHandler: GameStartHandler(gameUseCase: useCase),
            gameTimerHandler: GameTimerHandler(gameUseCase: useCase),
            gameTimerDisposalHandler: GameTimerDisposalHandler(gameUseCase: useCase),
            firingMoitonFilter: FiringMotionFilter(),
            reloadingMotionFilter: ReloadingMotionFilter(),
            weaponFireHandler: WeaponFireHandler(),
            weaponAutoReloadFilter: WeaponAutoReloadFilter(),
            weaponReloadHandler: WeaponReloadHandler(gameUseCase: useCase),
            weaponSelectHandler: WeaponSelectHandler(),
            targetHitFilter: TargetHitFilter(),
            targetHitHandler: TargetHitHandler(),
            reloadingMotionDetectionCounter: ReloadingMotionDetectionCounter()
        )
        let arContentController = ARContentController()
        let deviceMotionController = DeviceMotionController(coreMotionManager: CMMotionManager())
        vc.viewModel = viewModel
        vc.arContentController = arContentController
        vc.deviceMotionController = deviceMotionController
        return vc
    }
    
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>) {
        let vc = TutorialNavigator.assembleModules(
            transitionType: .gamePage,
            tutorialEndObserver: tutorialEndObserver
        )
        // TODO: 後でiOS16からの公式ハーフモーダルに変える
        viewController.present(vc, animated: true)
//        viewController.presentPanModal(vc)
    }
    
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>) {
        let vc = WeaponChangeNavigator.assembleModules(
            weaponSelectObserver: weaponSelectObserver
        )
        viewController.present(vc, animated: true)
    }
    
    func dismissWeaponChangeView() {
        viewController.presentedViewController?.dismiss(animated: true)
    }
    
    func showResultView(score: Double) {
        let vc = ResultNavigator.assembleModules(score: score)
        viewController.present(vc, animated: true)
    }
}
