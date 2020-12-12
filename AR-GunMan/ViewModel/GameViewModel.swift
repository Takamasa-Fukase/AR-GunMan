//
//  GameViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2020/11/22.
//

import Foundation
import RxSwift
import RxCocoa

class GameViewModel {
    
    //input
    var rankingWillAppear: AnyObserver<Void>
    
    
    //output
    var dismissSwitchWeaponVC: Observable<Void>
    
    
    init() {
        
        let _dismissSwitchWeaponVC = PublishRelay<Void>()
        dismissSwitchWeaponVC = _dismissSwitchWeaponVC.asObservable()
        
        rankingWillAppear = AnyObserver<Void>() { _ in
            
            print("GameVM 武器選択を閉じる指示を流します")
                        
            _dismissSwitchWeaponVC.accept(Void())
        }
        
    }
    
    
}
