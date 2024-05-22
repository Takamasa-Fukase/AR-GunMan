//
//  GameNavigator2.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/14.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

protocol GameNavigator2Interface {
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>)
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>)
    func dismissWeaponChangeView()
    func showResultView(totalScore: Double)
}

final class GameNavigator2: GameNavigator2Interface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController2", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GameViewController2
        vc.modalPresentationStyle = .fullScreen
        
        let tutorialRepository = TutorialRepository()
        let timerRepository = TimerRepository()
        let useCase = GameUseCase2(
            tutorialRepository: tutorialRepository,
            timerRepository: timerRepository
        )
        let navigator = GameNavigator(viewController: vc)
        let viewModel = GameViewModel2(
            useCase: useCase,
            navigator: navigator
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

