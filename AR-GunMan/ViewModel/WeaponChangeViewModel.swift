//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import RxSwift
import RxCocoa
import FSPagerView

protocol WeaponChangeDelegate: AnyObject {
    func weaponSelected(_ index: Int)
}

class WeaponChangeViewModel: NSObject {
    let dismiss: Observable<Void>
    
    private let weaponItemTappedRelay = PublishRelay<Int>()
    private let dismissRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
            
    init(dependency delegate: WeaponChangeDelegate?) {
        let dismissRelay = PublishRelay<Void>()
        self.dismiss = dismissRelay.asObservable()

        weaponItemTappedRelay
            .subscribe(onNext: { element in
                delegate?.weaponSelected(element)
                dismissRelay.accept(Void())
            }).disposed(by: disposeBag)
    }
}

extension WeaponChangeViewModel: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        weaponItemTappedRelay.accept(index)
    }
}
