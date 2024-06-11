//
//  TutorialViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
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
        let horizontalPageIndex: Observable<Int>
        let bottomButtonTapped: Observable<Void>
    }
    
    struct Output {
        let setupUI: Observable<TransitType>
        let buttonText: Observable<String>
        let pageControllIndex: Observable<Int>
        let scrollToNextPage: Observable<Void>
    }
    
    struct State {}
    
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
    
    func transform(input: Input) -> Output {
        let horizontalPageIndexRelay = BehaviorRelay<Int>(value: 0)
        
        input.viewDidDisappear
            .subscribe(onNext: { [weak self] element in
                self?.tutorialEndEventReceiver?.accept(Void())
            }).disposed(by: disposeBag)
        
        input.horizontalPageIndex
            .bind(to: horizontalPageIndexRelay)
            .disposed(by: disposeBag)
        
        input.bottomButtonTapped
            .filter({_ in horizontalPageIndexRelay.value >= 2})
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            }).disposed(by: disposeBag)
        
        let setupUI = input.viewDidLoad
            .map({ [weak self] _ in
                return self?.transitionType ?? .topPage
            })
        
        let buttonText = horizontalPageIndexRelay
            .map({($0 < 2) ? "NEXT" : "OK"})
        
        let scrollToNextPage = input.bottomButtonTapped
            .filter({_ in horizontalPageIndexRelay.value < 2})
        
        return Output(
            setupUI: setupUI,
            buttonText: buttonText,
            pageControllIndex: horizontalPageIndexRelay.asObservable(),
            scrollToNextPage: scrollToNextPage
        )
    }
}
