//
//  TutorialViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

class TutorialViewModel {
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
    
    struct Dependency {
        let navigator: TutorialNavigatorInterface
        let transitionType: TransitType
        weak var tutorialEndObserver: PublishRelay<Void>?
    }
    
    let navigator: TutorialNavigatorInterface
    private let transitionType: TransitType
    private let dependency: Dependency
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.navigator = dependency.navigator
        self.transitionType = dependency.transitionType
        self.dependency = dependency
    }
    
    func transform(input: Input) -> Output {
        let horizontalPageIndexRelay = BehaviorRelay<Int>(value: 0)
        
        input.viewDidDisappear
            .subscribe(onNext: { [weak self] element in
                self?.dependency.tutorialEndObserver?.accept(Void())
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
