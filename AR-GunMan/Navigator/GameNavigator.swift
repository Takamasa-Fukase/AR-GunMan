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
        let useCase = GameUseCase(coreMotionRepository: coreMotionRepository)
        let navigator = GameNavigator(viewController: vc)
        let vmDependency = GameViewModel.Dependency(
            tutorialRepository: TutorialRepository(),
            useCase: useCase,
            navigator: navigator
        )
        vc.viewModel = GameViewModel(dependency: vmDependency)
        return vc
    }
    
    func showTutorialView(tutorialEndObserver: PublishRelay<Void>) {
        let storyboard = UIStoryboard(name: "TutorialViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! TutorialViewController
        vc.vmDependency = .init(transitionType: .gamePage,
                                tutorialEndObserver: tutorialEndObserver)
        viewController?.presentPanModal(vc)
    }
    
    func showWeaponChangeView(weaponSelectObserver: PublishRelay<WeaponType>) {
        let storyboard = UIStoryboard(name: "WeaponChangeViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! WeaponChangeViewController
        vc.vmDependency = .init(weaponSelectObserver: weaponSelectObserver)
        viewController?.present(vc, animated: true)
    }
    
    func dismissWeaponChangeView() {
        viewController?.presentedViewController?.dismiss(animated: true)
    }
    
    func showResultView(totalScore: Double) {
        let storyboard = UIStoryboard(name: "ResultViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ResultViewController
        vc.vmDependency = .init(rankingRepository: RankingRepository(),
                                totalScore: totalScore)
        viewController?.present(vc, animated: true)
    }
}
