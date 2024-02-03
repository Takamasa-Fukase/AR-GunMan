//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import RxSwift
import RxCocoa

class TopViewModel {
    let startButtonImage: Observable<UIImage?>
    let rankingButtonImage: Observable<UIImage?>
    let howToPlayButtonImage: Observable<UIImage?>
    let showGame: Observable<Void>
    let showRanking: Observable<Void>
    let showTutorial: Observable<Void>
    let showSettings: Observable<Void>

    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let startButtonTapped: Observable<Void>
        let rankingButtonTapped: Observable<Void>
        let howToPlayButtonTapped: Observable<Void>
        let settingsButtonTapped: Observable<Void>
    }
    
    struct Dependency {
        let buttonImageSwitcher: TopPageButtonImageSwitcher
    }

    init(input: Input,
         dependency: Dependency) {
        let showGameRelay = PublishRelay<Void>()
        self.showGame = showGameRelay.asObservable()
        
        input.viewDidAppear
            .subscribe(onNext: { element in
                if UserDefaults.isReplay {
                    UserDefaults.isReplay = false
                    showGameRelay.accept(Void())
                }
            }).disposed(by: disposeBag)
        
        self.startButtonImage = dependency.buttonImageSwitcher.image
            .filter({$0.type == .start})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        self.rankingButtonImage = dependency.buttonImageSwitcher.image
            .filter({$0.type == .ranking})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        self.howToPlayButtonImage = dependency.buttonImageSwitcher.image
            .filter({$0.type == .howToPlay})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})

        dependency.buttonImageSwitcher.image
            .filter({$0.type == .start && !$0.isSwitched})
            .map({ _ in})
            .bind(to: showGameRelay)
            .disposed(by: disposeBag)
        
        self.showRanking = dependency.buttonImageSwitcher.image
            .filter({$0.type == .ranking && !$0.isSwitched})
            .map({_ in})
        
        self.showTutorial = dependency.buttonImageSwitcher.image
            .filter({$0.type == .howToPlay && !$0.isSwitched})
            .map({_ in})
        
        self.showSettings = dependency.buttonImageSwitcher.image
            .filter({$0.type == .settings && !$0.isSwitched})
            .map({_ in})
        
        input.startButtonTapped
            .subscribe(onNext: { _ in
                dependency.buttonImageSwitcher.switchAndRevert(of: .start)
            }).disposed(by: disposeBag)
        
        input.rankingButtonTapped
            .subscribe(onNext: { _ in
                dependency.buttonImageSwitcher.switchAndRevert(of: .ranking)
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { _ in
                dependency.buttonImageSwitcher.switchAndRevert(of: .howToPlay)
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { _ in
                dependency.buttonImageSwitcher.switchAndRevert(of: .settings)
            }).disposed(by: disposeBag)
    }
}
