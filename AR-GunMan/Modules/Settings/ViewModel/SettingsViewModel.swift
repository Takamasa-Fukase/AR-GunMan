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
    let showRanking: Observable<Void>
    let dismiss: Observable<Void>
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let worldRankingButtonTapped: Observable<Void>
        let privacyPolicyButtonTapped: Observable<Void>
        let developerConctactButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
    }
    
    init(input: Input) {
        let _openSafariView = PublishRelay<String>()
        self.openSafariView = _openSafariView.asObservable()
        
        self.showRanking = input.worldRankingButtonTapped
            .map({_ in})
        
        input.privacyPolicyButtonTapped
            .subscribe(onNext: { _ in
                _openSafariView.accept(SettingsConst.privacyPolicyURL)
            }).disposed(by: disposeBag)
        
        input.developerConctactButtonTapped
            .subscribe(onNext: { _ in
                _openSafariView.accept(SettingsConst.developerContactURL)
            }).disposed(by: disposeBag)
        
        self.dismiss = input.backButtonTapped
            .map({_ in})
    }
}


