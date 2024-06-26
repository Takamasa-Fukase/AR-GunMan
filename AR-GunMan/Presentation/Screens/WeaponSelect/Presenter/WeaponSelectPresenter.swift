//
//  WeaponSelectPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

struct WeaponSelectControllerInput {
    let viewDidLayoutSubviews: Observable<Void>
    let itemSelected: Observable<Int>
}

struct WeaponSelectViewModel {
    let adjustPageViewItemSize: Driver<Void>
}

protocol WeaponSelectPresenterInterface {
    func transform(input: WeaponSelectControllerInput) -> WeaponSelectViewModel
}

final class WeaponSelectPresenter: WeaponSelectPresenterInterface {
    private let navigator: WeaponSelectNavigatorInterface
    private weak var weaponSelectEventReceiver: PublishRelay<WeaponType>?
    private let disposeBag = DisposeBag()

    init(
        navigator: WeaponSelectNavigatorInterface,
        weaponSelectEventReceiver: PublishRelay<WeaponType>?
    ) {
        self.navigator = navigator
        self.weaponSelectEventReceiver = weaponSelectEventReceiver
    }
    
    func transform(input: WeaponSelectControllerInput) -> WeaponSelectViewModel {
        disposeBag.insert {
            // MARK: Event posts
            input.itemSelected
                .map({ WeaponType.allCases[$0] })
                .bind(to: weaponSelectEventReceiver ?? PublishRelay<WeaponType>())
            
            // MARK: Transitions
            input.itemSelected
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    self.navigator.dismiss()
                })
        }
        
        return WeaponSelectViewModel(
            adjustPageViewItemSize: input.viewDidLayoutSubviews
                .asDriverOnErrorJustComplete()
        )
    }
}
