//
//  WeaponSelectNavigator.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/16.
//

import RxCocoa

protocol WeaponSelectNavigatorInterface {
    func dismiss()
}

final class WeaponSelectNavigator: WeaponSelectNavigatorInterface {
    private unowned let viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    static func assembleModules(
        weaponSelectEventReceiver: PublishRelay<WeaponType>?
    ) -> UIViewController {
        let storyboard = UIStoryboard(name: WeaponSelectViewController.className, bundle: nil)
        let vc = storyboard.instantiateInitialViewController() as! WeaponSelectViewController
        vc.presenter = WeaponSelectPresenter(
            navigator: WeaponSelectNavigator(viewController: vc),
            weaponSelectEventReceiver: weaponSelectEventReceiver
        )
        return vc
    }
    
    func dismiss() {
        viewController.dismiss(animated: true)
    }
}
