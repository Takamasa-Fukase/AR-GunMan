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
    
    struct Output {}
    
    struct State {}
    
    private let navigator: WeaponChangeNavigatorInterface
    private weak var weaponSelectObserver: PublishRelay<WeaponType>?
    
    private let disposeBag = DisposeBag()
            
    init(
        navigator: WeaponChangeNavigatorInterface,
        weaponSelectObserver: PublishRelay<WeaponType>?
    ) {
        self.navigator = navigator
        self.weaponSelectObserver = weaponSelectObserver
    }
    
    func transform(input: Input) -> Output {
        input.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                self.weaponSelectObserver?.accept(WeaponType.allCases[index])
                self.navigator.dismiss()
            }).disposed(by: disposeBag)
        
        return Output()
    }
}
