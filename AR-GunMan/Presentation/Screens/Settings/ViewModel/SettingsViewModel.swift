//
//  SettingsViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import RxSwift
import RxCocoa

final class SettingsViewModel: ViewModelType {
    struct Input {
        let worldRankingButtonTapped: Observable<Void>
        let privacyPolicyButtonTapped: Observable<Void>
        let developerConctactButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rankingViewShowed: Observable<Void>
        let privacyPolicyViewShowed: Observable<Void>
        let developerContactViewShowed: Observable<Void>
        let viewDismissed: Observable<Void>
    }
    
    struct State {}
    
    private let navigator: SettingsNavigatorInterface
    
    init(navigator: SettingsNavigatorInterface) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        let rankingViewShowed = input.worldRankingButtonTapped
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showRanking()
            })
        
        let privacyPolicyViewShowed = input.privacyPolicyButtonTapped
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showPrivacyPolicy()
            })
        
        let developerContactViewShowed = input.developerConctactButtonTapped
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showDeveloperContact()
            })
        
        let viewDismissed = input.backButtonTapped
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            })

        return Output(
            rankingViewShowed: rankingViewShowed,
            privacyPolicyViewShowed: privacyPolicyViewShowed,
            developerContactViewShowed: developerContactViewShowed,
            viewDismissed: viewDismissed
        )
    }
}


