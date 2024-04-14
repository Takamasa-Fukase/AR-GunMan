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
        let showGame: Observable<Void>
        let showSettings: Observable<Void>
        let showTutorial: Observable<Void>
    }
    
    struct Dependency {
        let buttonImageSwitcher: TopPageButtonImageSwitcher
    }
    
    private let dependency: Dependency
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.dependency = dependency
    }

    func transform(input: Input) -> Output {
        let showGameRelay = PublishRelay<Void>()
        
        dependency.buttonImageSwitcher.image
            .filter({$0.type == .start && !$0.isSwitched})
            .map({ _ in})
            .bind(to: showGameRelay)
            .disposed(by: disposeBag)
        
        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dependency.buttonImageSwitcher.switchAndRevert(of: .start)
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dependency.buttonImageSwitcher.switchAndRevert(of: .settings)
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dependency.buttonImageSwitcher.switchAndRevert(of: .howToPlay)
            }).disposed(by: disposeBag)
                
        input.viewDidAppear
            .subscribe(onNext: { element in
                if UserDefaults.isReplay {
                    UserDefaults.isReplay = false
                    showGameRelay.accept(Void())
                }
            }).disposed(by: disposeBag)
        
        let startButtonImage = dependency.buttonImageSwitcher.image
            .filter({$0.type == .start})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        let settingsButtonImage = dependency.buttonImageSwitcher.image
            .filter({$0.type == .settings})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        let howToPlayButtonImage = dependency.buttonImageSwitcher.image
            .filter({$0.type == .howToPlay})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        let showGame = showGameRelay.asObservable()

        let showSettings = dependency.buttonImageSwitcher.image
            .filter({$0.type == .settings && !$0.isSwitched})
            .map({_ in})
        
        let showTutorial = dependency.buttonImageSwitcher.image
            .filter({$0.type == .howToPlay && !$0.isSwitched})
            .map({_ in})

        return Output(
            startButtonImage: startButtonImage,
            settingsButtonImage: settingsButtonImage,
            howToPlayButtonImage: howToPlayButtonImage,
            showGame: showGame,
            showSettings: showSettings,
            showTutorial: showTutorial
        )
    }
}
