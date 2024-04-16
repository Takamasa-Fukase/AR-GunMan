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
        let dismiss: Observable<Void>
    }
    
    struct State {
        
    }
    
    private weak var weaponSelectObserver: PublishRelay<WeaponType>?
            
    init(weaponSelectObserver: PublishRelay<WeaponType>?) {
        self.weaponSelectObserver = weaponSelectObserver
    }
    
    func transform(input: Input) -> Output {
        let dismiss = input.itemSelected
            .map({ [weak self] index in
                guard let self = self else { return }
                self.weaponSelectObserver?.accept(WeaponType.allCases[index])
            })
        
        return Output(dismiss: dismiss)
    }
}
