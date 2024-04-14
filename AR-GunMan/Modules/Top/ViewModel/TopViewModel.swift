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
    
    struct Dependency {
        let navigator: TopNavigator
        let buttonImageSwitcher: TopPageButtonImageSwitcher
    }
    
    private let navigator: TopNavigator
    private let buttonImageSwitcher: TopPageButtonImageSwitcher
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.navigator = dependency.navigator
        self.buttonImageSwitcher = dependency.buttonImageSwitcher
    }

    func transform(input: Input) -> Output {
//        input.viewDidAppear
//            .subscribe(onNext: { element in
//                if UserDefaults.isReplay {
//                    UserDefaults.isReplay = false
//                    showGameRelay.accept(Void())
//                }
//            }).disposed(by: disposeBag)

        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.buttonImageSwitcher.switchAndRevert(of: .start)
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.buttonImageSwitcher.switchAndRevert(of: .settings)
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.buttonImageSwitcher.switchAndRevert(of: .howToPlay)
            }).disposed(by: disposeBag)
         
        buttonImageSwitcher.image
            .subscribe(onNext: { [weak self] element in
                guard let self = self else { return }
                switch element.type {
                case .start:
                    // TODO: ButtonImageSwitcherを見直す時にreplay時の遷移の考慮を再度追加する
                    self.navigator.showGame()
                case .settings:
                    self.navigator.showSettings()
                case .howToPlay:
                    self.navigator.showTutorial()
                }
            }).disposed(by: disposeBag)
        
        let startButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .start})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        let settingsButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .settings})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        let howToPlayButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .howToPlay})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})

        return Output(
            startButtonImage: startButtonImage,
            settingsButtonImage: settingsButtonImage,
            howToPlayButtonImage: howToPlayButtonImage
        )
    }
}
