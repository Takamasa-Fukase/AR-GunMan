//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import RxSwift
import RxCocoa

protocol WeaponChangeDelegate: AnyObject {
    func weaponSelected(_ index: Int)
}

class WeaponChangeViewModel {
    // input
    let weaponItemTapped: AnyObserver<Int>
    
    // output
    let dismiss: Observable<Void>
            
    init(dependency delegate: WeaponChangeDelegate?) {
        let dismissRelay = PublishRelay<Void>()
        self.dismiss = dismissRelay.asObservable()
        
        self.weaponItemTapped = AnyObserver<Int>() { event in
            guard let index = event.element else { return }
            delegate?.weaponSelected(index)
            dismissRelay.accept(Void())
        }
    }
}
