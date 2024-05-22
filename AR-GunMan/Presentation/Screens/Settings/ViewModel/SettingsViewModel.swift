//
//  SettingsViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingsViewModel: ViewModelType {
    struct Input {
        let worldRankingButtonTapped: Observable<Void>
        let privacyPolicyButtonTapped: Observable<Void>
        let developerConctactButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
    }
    
    struct Output {}
    
    struct State {}
    
    private let navigator: SettingsNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(navigator: SettingsNavigatorInterface) {
        self.navigator = navigator
    }
    
    func transform(input: Input) -> Output {
        input.worldRankingButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showRanking()
            }).disposed(by: disposeBag)
        
        input.privacyPolicyButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showPrivacyPolicy()
            }).disposed(by: disposeBag)
        
        input.developerConctactButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showDeveloperContact()
            }).disposed(by: disposeBag)
        
        input.backButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            }).disposed(by: disposeBag)
        
        return Output()
    }
}


