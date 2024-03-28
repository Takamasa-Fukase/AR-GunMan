//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import FSPagerView
import RxSwift
import RxCocoa

class WeaponChangeViewModel: NSObject {
    struct Input {}
    
    struct Output {
        let dismiss: Observable<Void>
    }
    
    struct Dependency {
        weak var weaponSelectObserver: PublishRelay<WeaponType>?
    }
    
    private let dependency: Dependency
    private let dismissRelay = PublishRelay<Void>()
            
    init(dependency: Dependency) {
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        return Output(dismiss: dismissRelay.asObservable())
    }
}

extension WeaponChangeViewModel: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        dependency.weaponSelectObserver?.accept(WeaponType.allCases[index])
        dismissRelay.accept(Void())
    }
}
