//
//  SettingsPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

final class SettingsPresenter: PresenterType {
    struct ControllerEvents {
        let worldRankingButtonTapped: Observable<Void>
        let privacyPolicyButtonTapped: Observable<Void>
        let developerConctactButtonTapped: Observable<Void>
        let backButtonTapped: Observable<Void>
    }
    struct ViewModel {}
    
    private let navigator: SettingsNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(navigator: SettingsNavigatorInterface) {
        self.navigator = navigator
    }
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        disposeBag.insert {
            // MARK: 画面遷移
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
        
        return ViewModel()
    }
}
