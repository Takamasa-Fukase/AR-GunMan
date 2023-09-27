//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import RxSwift
import RxCocoa
import FSPagerView

class WeaponChangeViewModel: NSObject {
    let dismiss: Observable<Void>
    
    private let weaponItemTappedRelay = PublishRelay<Int>()
    private let disposeBag = DisposeBag()
    
    struct Dependency {
        let currentWeapon: CurrentWeapon
        let timeCounter: TimeCounter
    }
            
    init(dependency: Dependency) {
        let dismissRelay = PublishRelay<Void>()
        self.dismiss = dismissRelay.asObservable()

        weaponItemTappedRelay
            .subscribe(onNext: { element in
                dependency.currentWeapon.changeWeaponType(
                    to: WeaponType.allCases[element]
                )
                dismissRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        dependency.timeCounter.countEnded
            .bind(to: dismissRelay)
            .disposed(by: disposeBag)
    }
}

extension WeaponChangeViewModel: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        weaponItemTappedRelay.accept(index)
    }
}
