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
    struct Input {
        let worldRankingButtonTapped: Observable<Void>
        let privacyPolicyButtonTapped: Observable<Void>
        let developerConctactButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
    }
    
    struct Output {
        let showRanking: Observable<Void>
        let openSafariView: Observable<String>
        let dismiss: Observable<Void>
    }
    
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let openSafariViewRelay = PublishRelay<String>()
        
        input.privacyPolicyButtonTapped
            .subscribe(onNext: { _ in
                openSafariViewRelay.accept(SettingsConst.privacyPolicyURL)
            }).disposed(by: disposeBag)
        
        input.developerConctactButtonTapped
            .subscribe(onNext: { _ in
                openSafariViewRelay.accept(SettingsConst.developerContactURL)
            }).disposed(by: disposeBag)
        
        return Output(
            showRanking: input.worldRankingButtonTapped,
            openSafariView: openSafariViewRelay.asObservable(),
            dismiss: input.backButtonTapped
        )
    }
}


