//
//  SimpleGameNavigator2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 27/5/24.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

protocol SimpleGameNavigator2Interface {
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>)
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>)
    func dismissWeaponChangeView()
    func showResultView(totalScore: Double)
}

final class SimpleGameNavigator2: SimpleGameNavigator2Interface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "SimpleGameViewController2", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! SimpleGameViewController2
        vc.modalPresentationStyle = .fullScreen
        
        let navigator = SimpleGameNavigator2(viewController: vc)
        let useCase = GameUseCase2(
            tutorialRepository: TutorialRepository(),
            timerRepository: TimerRepository()
        )
        let viewModel = SimpleGameViewModel2(
            useCase: useCase,
            navigator: navigator,
            tutorialSeenStatusHandler: TutorialSeenStatusHandler(gameUseCase: useCase),
            gameStartHandler: GameStartHandler(gameUseCase: useCase),
            gameTimerHandler: GameTimerHandler(gameUseCase: useCase),
            firingMoitonFilter: FiringMotionFilter(),
            reloadingMotionFilter: ReloadingMotionFilter(),
            weaponFireHandler: WeaponFireHandler(),
            weaponAutoReloadHandler: WeaponAutoReloadHandler(),
            weaponReloadHandler: WeaponReloadHandler(gameUseCase: useCase),
            weaponSelectHandler: WeaponSelectHandler(),
            targetHitHandler: TargetHitHandler()
        )
        let gameSceneController = GameSceneController()
        let coreMotionController = CoreMotionController(coreMotionManager: CMMotionManager())
        vc.viewModel = viewModel
        vc.gameSceneController = gameSceneController
        vc.coreMotionController = coreMotionController
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
    
    func showResultView(totalScore: Double) {
        let vc = ResultNavigator.assembleModules(totalScore: totalScore)
        viewController.present(vc, animated: true)
    }
}
