//
//  WeaponChangeNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import RxCocoa

protocol WeaponChangeNavigatorInterface {
    func dismiss()
}

final class WeaponChangeNavigator: WeaponChangeNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(
        weaponSelectEventReceiver: PublishRelay<WeaponType>?
    ) -> UIViewController {
        let storyboard = UIStoryboard(name: WeaponChangeViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! WeaponChangeViewController
        let navigator = WeaponChangeNavigator(viewController: vc)
        let viewModel = WeaponChangeViewModel(
            navigator: navigator,
            weaponSelectEventReceiver: weaponSelectEventReceiver
        )
        vc.viewModel = viewModel
        return vc
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
}
