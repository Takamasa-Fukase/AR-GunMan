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
        let viewDidDisappear: Observable<Void>
        let horizontalPageIndex: Observable<Int>
        let bottomButtonTapped: Observable<Void>
    }
    
    struct Output {
        let buttonText: Observable<String>
        let pageControllIndex: Observable<Int>
        let scrollToNextPage: Observable<Void>
        let dismiss: Observable<Void>
    }
    
    struct Dependency {
        let transitionType: TransitType
        weak var tutorialEndObserver: PublishRelay<Void>?
    }
    
    let transitionType: TransitType
    private let dependency: Dependency
    private let disposeBag = DisposeBag()
    
    init(dependency: Dependency) {
        self.dependency = dependency
        self.transitionType = dependency.transitionType
    }
    
    func transform(input: Input) -> Output {
        let horizontalPageIndexRelay = BehaviorRelay<Int>(value: 0)
        
        input.horizontalPageIndex
            .bind(to: horizontalPageIndexRelay)
            .disposed(by: disposeBag)
        
        let buttonText = horizontalPageIndexRelay
            .map({($0 < 2) ? "NEXT" : "OK"})
        
        let pageControllIndex = horizontalPageIndexRelay.asObservable()
        
        let scrollToNextPage = input.bottomButtonTapped
            .filter({_ in horizontalPageIndexRelay.value < 2})
        
        let dismiss = input.bottomButtonTapped
            .filter({_ in horizontalPageIndexRelay.value >= 2})
                
        input.viewDidDisappear
            .subscribe(onNext: { [weak self] element in
                self?.dependency.tutorialEndObserver?.accept(Void())
            }).disposed(by: disposeBag)
        
        return Output(
            buttonText: buttonText,
            pageControllIndex: pageControllIndex,
            scrollToNextPage: scrollToNextPage,
            dismiss: dismiss
        )
    }
}
