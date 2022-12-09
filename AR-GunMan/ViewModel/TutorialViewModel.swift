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
    
    //input
    let currentScrollViewIndex: AnyObserver<Int>
    let bottomButtonTapped: AnyObserver<Void>
    
    //output
    let pageControlValue: Observable<Int>
    let buttonText: Observable<String>
    let scrollPage: Observable<Void>
    let dismiss: Observable<Void>
    
    //other
    private let disposeBag = DisposeBag()
    
    init() {
        
        //output
        let _pageControlValue = BehaviorRelay<Int>(value: 0)
        self.pageControlValue = _pageControlValue.asObservable()
        
        let _buttonText = BehaviorRelay<String>(value: "NEXT")
        self.buttonText = _buttonText.asObservable()
        
        let _scrollPage = PublishRelay<Void>()
        self.scrollPage = _scrollPage.asObservable()
        
        let _dismiss = PublishRelay<Void>()
        self.dismiss = _dismiss.asObservable()
        
        //input
        let _currentScrollViewIndex = BehaviorRelay<Int>(value: 0)
        self.currentScrollViewIndex = AnyObserver<Int>() { event in
            guard let element = event.element else {return}
            _currentScrollViewIndex.accept(element)
        }
        let _ = _currentScrollViewIndex
            .subscribe(onNext: { element in
                _pageControlValue.accept(element)
                if element != 2 {
                    _buttonText.accept("NEXT")
                }else {
                    _buttonText.accept("OK")
                }
            }).disposed(by: disposeBag)
        
        self.bottomButtonTapped = AnyObserver<Void>() { _ in
            if _currentScrollViewIndex.value != 2 {
                _scrollPage.accept(Void())
            }else {
                _dismiss.accept(Void())
            }
        }
        
    }
    
    
}
