//
//  SettingsPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

struct SettingsControllerInput {
    let worldRankingButtonTapped: Observable<Void>
    let privacyPolicyButtonTapped: Observable<Void>
    let developerConctactButtonTapped: Observable<Void>
    let backButtonTapped: Observable<Void>
}

protocol SettingsPresenterInterface {
    func transform(input: SettingsControllerInput)
}

final class SettingsPresenter: SettingsPresenterInterface {
    private let navigator: SettingsNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(navigator: SettingsNavigatorInterface) {
        self.navigator = navigator
    }
    
    func transform(input: SettingsControllerInput) {
        disposeBag.insert {
            // MARK: Transitions
            input.worldRankingButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showRanking()
                })
            input.privacyPolicyButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showPrivacyPolicy()
                })
            input.developerConctactButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showDeveloperContact()
                })
            input.backButtonTapped
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.dismiss()
                })
        }
    }
}
