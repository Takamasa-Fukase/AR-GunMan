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
    let settingsButtonImage: Observable<UIImage?>
    let showGame: Observable<Void>
    let showRanking: Observable<Void>
    let showTutorial: Observable<Void>
    let showSettings: Observable<Void>
    let isReplay: Observable<Bool>

    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewDidAppear: Observable<Void>
        let startButtonTapped: Observable<Void>
        let rankingButtonTapped: Observable<Void>
        let howToPlayButtonTapped: Observable<Void>
        let settingsButtonTapped: Observable<Void>
    }

    init(input: Input,
         dependency buttonImageSwitcher: TopPageButtonImageSwitcher) {
        let isReplayRelay = PublishRelay<Bool>()
        self.isReplay = isReplayRelay.asObservable()
        
        input.viewDidAppear
            .subscribe(onNext: { element in
                isReplayRelay.accept(UserDefaults.isReplay)
            }).disposed(by: disposeBag)
        
        self.startButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .start})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        self.rankingButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .ranking})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        self.howToPlayButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .howToPlay})
            .map({$0.type.targetIcon(isSwitched: $0.isSwitched)})
        
        self.settingsButtonImage = buttonImageSwitcher.image
            .filter({$0.type == .settings})
            .map({$0.type.toolBoxIcon(isSwitched: $0.isSwitched)})
        
        self.showGame = buttonImageSwitcher.image
            .filter({$0.type == .start && !$0.isSwitched})
            .map({ _ in})
        
        self.showRanking = buttonImageSwitcher.image
            .filter({$0.type == .ranking && !$0.isSwitched})
            .map({_ in})
        
        self.showTutorial = buttonImageSwitcher.image
            .filter({$0.type == .howToPlay && !$0.isSwitched})
            .map({_ in})
        
        self.showSettings = buttonImageSwitcher.image
            .filter({$0.type == .settings && !$0.isSwitched})
            .map({_ in})
        
        input.startButtonTapped
            .subscribe(onNext: { _ in
                buttonImageSwitcher.switchAndRevert(of: .start)
            }).disposed(by: disposeBag)
        
        input.rankingButtonTapped
            .subscribe(onNext: { _ in
                buttonImageSwitcher.switchAndRevert(of: .ranking)
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { _ in
                buttonImageSwitcher.switchAndRevert(of: .howToPlay)
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { _ in
                buttonImageSwitcher.switchAndRevert(of: .settings)
            }).disposed(by: disposeBag)
    }
}
