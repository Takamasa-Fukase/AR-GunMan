//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import FSPagerView
import RxCocoa

class WeaponChangeViewModel: NSObject {
    struct Dependency {
        weak var weaponSelectObserver: PublishRelay<WeaponType>?
    }
    
    private let dependency: Dependency
            
    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension WeaponChangeViewModel: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        dependency.weaponSelectObserver?.accept(WeaponType.allCases[index])
    }
}
