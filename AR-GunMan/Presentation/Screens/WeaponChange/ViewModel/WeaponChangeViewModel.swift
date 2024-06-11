//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import RxSwift
import RxCocoa

final class WeaponChangeViewModel: ViewModelType {
    struct Input {
        let itemSelected: Observable<Int>
    }
    
    struct Output {
        let weaponSelectEventSent: Observable<WeaponType>
        let viewDismissed: Observable<Void>
    }
    
    struct State {}
    
    private let navigator: WeaponChangeNavigatorInterface
    private weak var weaponSelectEventReceiver: PublishRelay<WeaponType>?
                
    init(
        navigator: WeaponChangeNavigatorInterface,
        weaponSelectEventReceiver: PublishRelay<WeaponType>?
    ) {
        self.navigator = navigator
        self.weaponSelectEventReceiver = weaponSelectEventReceiver
    }
    
    func transform(input: Input) -> Output {
        let weaponSelectEventSent = input.itemSelected
            .map({ WeaponType.allCases[$0] })
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.weaponSelectEventReceiver?.accept($0)
            })
        
        let viewDismissed = input.itemSelected
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            })
            .map({ _ in })
        
        return Output(
            weaponSelectEventSent: weaponSelectEventSent,
            viewDismissed: viewDismissed
        )
    }
}
