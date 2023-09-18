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
    let openSafariView: Observable<String>
    let dismiss: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let developerConctactButtonTapped: Observable<Void>
        let privacyPolicyButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
    }
    
    init(input: Input) {
        let _openSafariView = PublishRelay<String>()
        self.openSafariView = _openSafariView.asObservable()
        
        let _dismiss = PublishRelay<Void>()
        self.dismiss = _dismiss.asObservable()
        
        input.developerConctactButtonTapped
            .subscribe(onNext: { _ in
                _openSafariView.accept(SettingsConst.developerContactURL)
            }).disposed(by: disposeBag)
        
        input.privacyPolicyButtonTapped
            .subscribe(onNext: { _ in
                _openSafariView.accept(SettingsConst.privacyPolicyURL)
            }).disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { _ in
                _dismiss.accept(Void())
            }).disposed(by: disposeBag)
    }
}


