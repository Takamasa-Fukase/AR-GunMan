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
    
    struct Dependency {
        let navigator: SettingsNavigatorInterface
    }
    
    init(dependency: Dependency) {
        self.navigator = dependency.navigator
    }
    
    private let navigator: SettingsNavigatorInterface
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) {
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
    }
}


