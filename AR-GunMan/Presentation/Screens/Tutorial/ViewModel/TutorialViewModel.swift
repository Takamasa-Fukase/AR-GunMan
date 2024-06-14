//
//  TutorialViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 11/6/24.
//

import RxSwift
import RxCocoa

final class TutorialViewModel: ViewModelType {
    enum TransitType {
        case topPage
        case gamePage
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewDidDisappear: Observable<Void>
        let pageIndexWhenScrollViewScrolled: Observable<Int>
        let bottomButtonTapped: Observable<Void>
        let backgroundViewTapped: Observable<Void>
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
        
        struct ViewModelAction {
            let viewDismissed: Observable<Void>
            let tutorialEndEventSent: Observable<Void>
        }
        
        struct OutputToView {
            let setupUI: Observable<Void>
            let insertBlurEffectView: Observable<Void>
            let buttonText: Observable<String>
            let pageControllIndex: Observable<Int>
            let scrollToNextPage: Observable<Void>
        }
    }
    
    struct State {}
    
    private let navigator: TutorialNavigatorInterface
    private let transitionType: TransitType
    private weak var tutorialEndEventReceiver: PublishRelay<Void>?
        
    init(
        navigator: TutorialNavigatorInterface,
        transitionType: TransitType,
        tutorialEndEventReceiver: PublishRelay<Void>?
    ) {
        self.navigator = navigator
        self.transitionType = transitionType
        self.tutorialEndEventReceiver = tutorialEndEventReceiver
    }
    
    func transform(input: Input) -> Output {
        // MARK: - ViewModelAction
        let viewDismissed = Observable
            .merge(
                input.bottomButtonTapped
                    .withLatestFrom(input.pageIndexWhenScrollViewScrolled)
                    .filter({ pageIndex in
                        return pageIndex >= 2
                    })
                    .map({ _ in }),
                input.backgroundViewTapped
            )
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            })
        
        let tutorialEndEventSent = input.viewDidDisappear
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.tutorialEndEventReceiver?.accept(())
            })
        
        
        // MARK: - OutputToView
        let setupUI = input.viewDidLoad
        
        let insertBlurEffectView = input.viewDidLoad
            .filter({ [weak self] _ in
                guard let self = self else { return false }
                return self.transitionType == .gamePage
            })
        
        let buttonText = input.pageIndexWhenScrollViewScrolled
            .map({ pageIndex in
                if pageIndex < 2 {
                    return "NEXT"
                }else {
                    return "OK"
                }
            })
        
        let pageControllIndex = input.pageIndexWhenScrollViewScrolled
        
        let scrollToNextPage = input.bottomButtonTapped
            .withLatestFrom(input.pageIndexWhenScrollViewScrolled)
            .filter({ pageIndex in
                return pageIndex < 2
            })
            .map({ _ in })
        
        
        return Output(
            viewModelAction: Output.ViewModelAction(
                viewDismissed: viewDismissed,
                tutorialEndEventSent: tutorialEndEventSent),
            outputToView: Output.OutputToView(
                setupUI: setupUI,
                insertBlurEffectView: insertBlurEffectView,
                buttonText: buttonText,
                pageControllIndex: pageControllIndex,
                scrollToNextPage: scrollToNextPage
            )
        )
    }
}

