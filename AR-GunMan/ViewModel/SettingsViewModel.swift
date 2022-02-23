//
//  SettingsViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel {
    
    //input
    let developerConctactButtonTapped: AnyObserver<Void>
    let privacyPolicyButtonTapped: AnyObserver<Void>
    let backButtonTapped: AnyObserver<Void>

    //output
    let openSafariView: Observable<String>
    let dismiss: Observable<Void>
    
    //other
    private let disposeBag = DisposeBag()
    
    init() {
        
        //output
        let _openSafariView = PublishRelay<String>()
        self.openSafariView = _openSafariView.asObservable()
        
        let _dismiss = PublishRelay<Void>()
        self.dismiss = _dismiss.asObservable()
        
        //input
        self.developerConctactButtonTapped = AnyObserver<Void>() { _ in
            _openSafariView.accept(SettingsConst.developerContactURL)
        }
        
        self.privacyPolicyButtonTapped = AnyObserver<Void>() { _ in
            _openSafariView.accept(SettingsConst.privacyPolicyURL)
        }
        
        self.backButtonTapped = AnyObserver<Void>() { _ in
            _dismiss.accept(Void())
        }
    }
    
    
}


