//
//  TutorialPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

struct TutorialControllerInput {
    let viewDidLoad: Observable<Void>
    let viewDidDisappear: Observable<Void>
    let pageIndexWhenScrollViewScrolled: Observable<Int>
    let bottomButtonTapped: Observable<Void>
    let backgroundViewTapped: Observable<Void>
}

struct TutorialViewModel {
    let insertBlurEffectView: Observable<Void>
    let buttonText: Observable<String>
    let pageControlIndex: Observable<Int>
    let scrollToNextPage: Observable<Void>
}

protocol TutorialPresenterInterface {
    func transform(input: TutorialControllerInput) -> TutorialViewModel
}

final class TutorialPresenter: TutorialPresenterInterface {
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
    
    func transform(input: TutorialControllerInput) -> TutorialViewModel {
        disposeBag.insert {
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
            
            // MARK: Others
            input.viewDidDisappear
                .bind(to: tutorialEndEventReceiver ?? PublishRelay<Void>())
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
        
        return TutorialViewModel(
            insertBlurEffectView: insertBlurEffectView,
            buttonText: buttonText,
            pageControlIndex: input.pageIndexWhenScrollViewScrolled,
            scrollToNextPage: scrollToNextPage
        )
    }
}
