//
//  TutorialViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol TutorialDelegate: AnyObject {
    func tutorialEnded()
}

class TutorialViewModel {
    let buttonText: Observable<String>
    let pageControllIndex: Observable<Int>
    let scrollToNextPage: Observable<Void>
    let dismiss: Observable<Void>
    let transitionType: TransitType

    private let disposeBag = DisposeBag()
    
    enum TransitType {
        case topPage
        case gamePage
    }
    
    struct Input {
        let viewDidDisappear: Observable<Void>
        let horizontalPageIndex: Observable<Int>
        let bottomButtonTapped: Observable<Void>
    }
    
    struct Dependency {
        let transitionType: TransitType
        var delegate: TutorialDelegate?
    }
    
    init(input: Input, dependency: Dependency) {
        let horizontalPageIndexRelay = BehaviorRelay<Int>(value: 0)
        
        input.horizontalPageIndex
            .bind(to: horizontalPageIndexRelay)
            .disposed(by: disposeBag)
        
        self.buttonText = horizontalPageIndexRelay
            .map({($0 < 2) ? "NEXT" : "OK"})
        
        self.pageControllIndex = horizontalPageIndexRelay.asObservable()
        
        self.scrollToNextPage = input.bottomButtonTapped
            .filter({_ in horizontalPageIndexRelay.value < 2})
        
        self.dismiss = input.bottomButtonTapped
            .filter({_ in horizontalPageIndexRelay.value >= 2})
        
        self.transitionType = dependency.transitionType
        
        input.viewDidDisappear
            .subscribe(onNext: { element in
                if dependency.transitionType == .gamePage {
                    UserDefaults.isTutorialAlreadySeen = true
                }
                dependency.delegate?.tutorialEnded()
            }).disposed(by: disposeBag)
    }
}
