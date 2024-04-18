//
//  ResultNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import UIKit
import PanModal
import RxSwift

protocol ResultNavigatorInterface: AnyObject {
    func showNameRegister(
        totalScore: Double,
        rankingListObservable: Observable<[Ranking]>,
        eventObserver: NameRegisterEventObserver
    )
    func backToTop()
    func showErrorAlert(_ error: Error)
}

final class ResultNavigator: ResultNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(totalScore: Double) -> UIViewController {
        let storyboard = UIStoryboard(name: "ResultViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! ResultViewController
        vc.modalPresentationStyle = .fullScreen
        let navigator = ResultNavigator(viewController: vc)
        let viewModel = ResultViewModel(
            navigator: navigator,
            rankingRepository: RankingRepository(),
            totalScore: totalScore
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func showNameRegister(
        totalScore: Double,
        rankingListObservable: Observable<[Ranking]>,
        eventObserver: NameRegisterEventObserver
    ) {
        let storyboard: UIStoryboard = UIStoryboard(name: "NameRegisterViewController", bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! NameRegisterViewController
        vc.modalPresentationStyle = .overCurrentContext
        // TODO: Dependencyを廃止して直がきにする
        let dependency = NameRegisterViewModel.Dependency(
            // TODO: RepoをUseCaseに差し替える
            rankingRepository: RankingRepository(),
            totalScore: totalScore,
            rankingListObservable: rankingListObservable,
            eventObserver: eventObserver
        )
        vc.vmDependency = vmDependency
        viewController.presentPanModal(vc)
    }
    
    func backToTop() {
        let topVC = viewController.presentingViewController?.presentingViewController as! TopViewController
        topVC.dismiss(animated: false)
    }
    
    func showErrorAlert(_ error: Error) {
        viewController.present(UIAlertController.errorAlert(error), animated: true)
    }
}
