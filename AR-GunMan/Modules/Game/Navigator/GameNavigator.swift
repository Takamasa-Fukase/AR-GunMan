//
//  GameNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/03/25.
//

import Foundation
import PanModal
import RxCocoa
import CoreMotion

protocol GameNavigatorInterface: AnyObject {
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>)
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>)
    func dismissWeaponChangeView()
    func showResultView(totalScore: Double)
}

class GameNavigator: GameNavigatorInterface {
    private weak var viewController: GameViewController?
    
    init(viewController: GameViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules() -> UIViewController {
        let storyboard: UIStoryboard = UIStoryboard(name: "GameViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! GameViewController
        vc.modalPresentationStyle = .fullScreen
        
        let coreMotionManager = CMMotionManager()
        let coreMotionRepository = CoreMotionRepository(coreMotionManager: coreMotionManager)
        let tutorialRepository = TutorialRepository()
        let useCase = GameUseCase(
            coreMotionRepository: coreMotionRepository,
            tutorialRepository: tutorialRepository
        )
        let navigator = GameNavigator(viewController: vc)
        let sceneManager = GameSceneManager(delegate: vc)
        let viewModel = GameViewModel(
            useCase: useCase,
            navigator: navigator,
            sceneManager: sceneManager
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>) {
        let vc = TutorialNavigator.assembleModules(
            transitionType: .gamePage,
            tutorialEndObserver: tutorialEndObserver
        )
        viewController?.presentPanModal(vc)
    }
    
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>) {
        let vc = WeaponChangeNavigator.assembleModules(
            weaponSelectObserver: weaponSelectObserver
        )
        viewController?.present(vc, animated: true)
    }
    
    func dismissWeaponChangeView() {
        viewController?.presentedViewController?.dismiss(animated: true)
    }
    
    func showResultView(totalScore: Double) {
        let storyboard = UIStoryboard(name: "ResultViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ResultViewController
        let viewModel = ResultViewModel(
            rankingRepository: RankingRepository(),
            totalScore: totalScore
        )
        vc.viewModel = viewModel
        viewController?.present(vc, animated: true)
    }
}
