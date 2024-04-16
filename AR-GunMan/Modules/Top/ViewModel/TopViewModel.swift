//
//  TopViewModel.swift
//  AR-GunMan
//
//  Created by 深瀬 貴将 on 2021/02/27.
//

import RxSwift
import RxCocoa

class TopViewModel: ViewModelType {
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

    }

    private let useCase: TopUseCase
    private let navigator: TopNavigatorInterface
    
    private let disposeBag = DisposeBag()
    
    init(
        useCase: TopUseCase,
        navigator: TopNavigatorInterface
    ) {
        self.useCase = useCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let startButtonImageRelay = PublishRelay<UIImage?>()
        let settingsButtonImageRelay = PublishRelay<UIImage?>()
        let howToPlayButtonImageRelay = PublishRelay<UIImage?>()
        
        input.viewDidAppear
            .flatMapLatest({ [weak self] in
                return self?.useCase.getNeedsReplay() ?? Observable.just(false)
            })
            .subscribe(onNext: { [weak self] needsReplay in
                guard let self = self else { return }
                if needsReplay {
                    self.useCase.setNeedsReplay(false)
                    self.navigator.showGame()
                }
            }).disposed(by: disposeBag)

        input.startButtonTapped
            .flatMapLatest({ [weak self] in
                return self?.useCase.getIsPermittedCameraAccess() ?? Observable.just(false)
            })
            .subscribe(onNext: { [weak self] isPermittedCameraAccess in
                guard let self = self else { return }
                if isPermittedCameraAccess {
                    self.switchAndRevertButtonImage(
                        buttonImageRelay: startButtonImageRelay,
                        onReverted: {
                            self.navigator.showGame()
                        })
                }else {
                    self.navigator.showCameraPermissionDescriptionAlert()
                }
            }).disposed(by: disposeBag)
        
        input.settingsButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.switchAndRevertButtonImage(
                    buttonImageRelay: settingsButtonImageRelay,
                    onReverted: {
                        self.navigator.showSettings()
                    })
            }).disposed(by: disposeBag)
        
        input.howToPlayButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.switchAndRevertButtonImage(
                    buttonImageRelay: howToPlayButtonImageRelay,
                    onReverted: {
                        self.navigator.showTutorial()
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
