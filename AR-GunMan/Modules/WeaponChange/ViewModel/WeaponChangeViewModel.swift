//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import RxSwift
import RxCocoa

class WeaponChangeViewModel {
    struct Input {
        let itemSelected: Observable<Int>
    }
    
    struct Output {
        let dismiss: Observable<Void>
    }
    
    struct Dependency {
        weak var weaponSelectObserver: PublishRelay<WeaponType>?
    }
    
    private let dependency: Dependency
            
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        let dismiss = input.itemSelected
            .map({ [weak self] index in
                guard let self = self else { return }
                self.dependency.weaponSelectObserver?.accept(WeaponType.allCases[index])
            })
        
        return Output(dismiss: dismiss)
    }
}
