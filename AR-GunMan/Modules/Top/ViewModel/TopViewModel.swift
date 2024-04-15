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
    }
    
    private let navigator: TopNavigator
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.navigator = dependency.navigator
    }

    func transform(input: Input) -> Output {
        let startButtonImageRelay = PublishRelay<UIImage?>()
        let settingsButtonImageRelay = PublishRelay<UIImage?>()
        let howToPlayButtonImageRelay = PublishRelay<UIImage?>()

        input.startButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.switchAndRevertButtonImage(
                    buttonImageRelay: startButtonImageRelay,
                    onReverted: {
                        // TODO: ButtonImageSwitcherを見直す時にreplay時の遷移の考慮を再度追加する
                        self?.navigator.showGame()
                    })
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.switchAndRevertButtonImage(
                    buttonImageRelay: settingsButtonImageRelay,
                    onReverted: {
                        self?.navigator.showSettings()
                    })
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.switchAndRevertButtonImage(
                    buttonImageRelay: howToPlayButtonImageRelay,
                    onReverted: {
                        self?.navigator.showTutorial()
                    })
            }).disposed(by: disposeBag)
        
        return Output(
            startButtonImage: startButtonImageRelay.asObservable(),
            settingsButtonImage: settingsButtonImageRelay.asObservable(),
            howToPlayButtonImage: howToPlayButtonImageRelay.asObservable()
        )
    }
    
    private func switchAndRevertButtonImage(
        buttonImageRelay: PublishRelay<UIImage?>,
        onReverted: (@escaping () -> Void)
    ) {
        AudioUtil.playSound(of: TopConst.iconChangingSound)
        buttonImageRelay.accept(TopConst.targetIcon(isSwitched: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + TopConst.iconRevertInterval) {
            buttonImageRelay.accept(TopConst.targetIcon(isSwitched: false))
            onReverted()
        }
    }
}
