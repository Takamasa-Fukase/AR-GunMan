//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import RxSwift
import RxCocoa

class TopViewModel {
    struct Input {
        let viewDidAppear: Observable<Void>
        let startButtonTapped: Observable<Void>
        let settingsButtonTapped: Observable<Void>
        let howToPlayButtonTapped: Observable<Void>
    }
    
    struct Output {
        let startButtonImage: Observable<UIImage?>
        let settingsButtonImage: Observable<UIImage?>
        let howToPlayButtonImage: Observable<UIImage?>
    }
    
    struct State {
        let isStartButtonImageSwitched = BehaviorRelay<Bool>(value: false)
        let isSettingButtonImageSwitched = BehaviorRelay<Bool>(value: false)
        let isHowToPlayButtonImageSwitched = BehaviorRelay<Bool>(value: false)
    }
    
    struct Dependency {
        let navigator: TopNavigator
    }
    
    private let navigator: TopNavigator
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.navigator = dependency.navigator
    }

    func transform(input: Input) -> Output {
//        input.viewDidAppear
//            .subscribe(onNext: { element in
//                if UserDefaults.isReplay {
//                    UserDefaults.isReplay = false
//                    showGameRelay.accept(Void())
//                }
//            }).disposed(by: disposeBag)
        
        let state = State()
        
        func switchAndRevert(of type: TopPageButtonType) {
            AudioUtil.playSound(of: type.iconChangingSound)
            changeIcon(of: type, isSwitched: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + type.iconRevertInterval) {
                changeIcon(of: type, isSwitched: false)
                transit(of: type)
            }
        }
        
        func changeIcon(of type: TopPageButtonType, isSwitched: Bool) {
            switch type {
            case .start:
                state.isStartButtonImageSwitched.accept(isSwitched)
            case .settings:
                state.isSettingButtonImageSwitched.accept(isSwitched)
            case .howToPlay:
                state.isHowToPlayButtonImageSwitched.accept(isSwitched)
            }
        }
        
        func transit(of type: TopPageButtonType) {
            switch type {
            case .start:
                // TODO: ButtonImageSwitcherを見直す時にreplay時の遷移の考慮を再度追加する
                self.navigator.showGame()
            case .settings:
                self.navigator.showSettings()
            case .howToPlay:
                self.navigator.showTutorial()
            }
        }

        input.startButtonTapped
            .subscribe(onNext: { _ in
                switchAndRevert(of: .start)
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { _ in
                switchAndRevert(of: .settings)
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { _ in
                switchAndRevert(of: .howToPlay)
            }).disposed(by: disposeBag)

        let startButtonImage = state.isStartButtonImageSwitched
            .map({ TopPageButtonType.start.targetIcon(isSwitched: $0) })
        
        let settingsButtonImage = state.isSettingButtonImageSwitched
            .map({ TopPageButtonType.settings.targetIcon(isSwitched: $0) })
        
        let howToPlayButtonImage = state.isHowToPlayButtonImageSwitched
            .map({ TopPageButtonType.howToPlay.targetIcon(isSwitched: $0) })
        
        return Output(
            startButtonImage: startButtonImage,
            settingsButtonImage: settingsButtonImage,
            howToPlayButtonImage: howToPlayButtonImage
        )
    }
}
