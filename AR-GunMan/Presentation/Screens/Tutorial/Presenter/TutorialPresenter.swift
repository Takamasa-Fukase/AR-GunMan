//
//  TutorialPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

final class TutorialPresenter: PresenterType {
    struct ControllerEvents {
        let viewDidLoad: Observable<Void>
        let viewDidDisappear: Observable<Void>
        let pageIndexWhenScrollViewScrolled: Observable<Int>
        let bottomButtonTapped: Observable<Void>
        let backgroundViewTapped: Observable<Void>
    }
    struct ViewModel {
        let insertBlurEffectView: Driver<Void>
        let buttonText: Driver<String>
        let pageControlIndex: Driver<Int>
        let scrollToNextPage: Driver<Void>
    }
    enum TransitType {
        case topPage
        case gamePage
    }
    
    private let navigator: TutorialNavigatorInterface
    private let transitionType: TransitType
    private weak var tutorialEndEventReceiver: PublishRelay<Void>?
    private let disposeBag = DisposeBag()
    
    init(
        navigator: TutorialNavigatorInterface,
        transitionType: TransitType,
        tutorialEndEventReceiver: PublishRelay<Void>?
    ) {
        self.navigator = navigator
        self.transitionType = transitionType
        self.tutorialEndEventReceiver = tutorialEndEventReceiver
    }
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        disposeBag.insert {
            // MARK: Event sendings to receivers
            input.viewDidDisappear
                .bind(to: tutorialEndEventReceiver ?? PublishRelay<Void>())
            
            // MARK: Transitions
            Observable
                .merge(
                    input.bottomButtonTapped
                        .withLatestFrom(input.pageIndexWhenScrollViewScrolled)
                        .filter({ $0 >= 2 })
                        .mapToVoid(),
                    input.backgroundViewTapped
                )
                .subscribe(onNext: { [weak self] in
                    guard let self = self else {return}
                    self.navigator.dismiss()
                })
        }
        
        let insertBlurEffectView = input.viewDidLoad
            .filter({ [weak self] _ in
                guard let self = self else { return false }
                return self.transitionType == .gamePage
            })
        
        let buttonText = input.pageIndexWhenScrollViewScrolled
            .map({ $0 < 2 ? "NEXT" : "OK" })
        
        let scrollToNextPage = input.bottomButtonTapped
            .withLatestFrom(input.pageIndexWhenScrollViewScrolled)
            .filter({ $0 < 2 })
            .mapToVoid()
        
        return ViewModel(
            insertBlurEffectView: insertBlurEffectView
                .asDriverOnErrorJustComplete(),
            buttonText: buttonText
                .asDriverOnErrorJustComplete(),
            pageControlIndex: input.pageIndexWhenScrollViewScrolled
                .asDriverOnErrorJustComplete(),
            scrollToNextPage: scrollToNextPage
                .asDriverOnErrorJustComplete()
        )
    }
}
