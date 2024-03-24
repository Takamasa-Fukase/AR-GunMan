//
//  WeaponChangeViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 21/1/23.
//

import FSPagerView

protocol WeaponChangeDelegate: AnyObject {
    func weaponSelected(_ weaponType: WeaponType)
}

class WeaponChangeViewModel: NSObject {
    let dependency: Dependency
    
    struct Dependency {
        weak var delegate: WeaponChangeDelegate?
    }
            
    init(dependency: Dependency) {
        self.dependency = dependency
    }
}

extension WeaponChangeViewModel: FSPagerViewDelegate {
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        dependency.delegate?.weaponSelected(WeaponType.allCases[index])
    }
}
