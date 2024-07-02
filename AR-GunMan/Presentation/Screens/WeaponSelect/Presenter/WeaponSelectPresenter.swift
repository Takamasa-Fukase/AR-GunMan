//
//  WeaponSelectPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

final class WeaponSelectPresenter: PresenterType {
    struct ControllerEvents {
        let viewDidLayoutSubviews: Observable<Void>
        let itemSelected: Observable<Int>
    }
    struct ViewModel {
        let adjustPageViewItemSize: Driver<Void>
    }
    
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
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        disposeBag.insert {
            // MARK: Event sendings to receivers
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
        
        return ViewModel(
            adjustPageViewItemSize: input.viewDidLayoutSubviews
                .asDriverOnErrorJustComplete()
        )
    }
}
