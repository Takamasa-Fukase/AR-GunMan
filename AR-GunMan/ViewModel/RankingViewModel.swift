//
//  RankingViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

class RankingViewModel {

    //input
    let getRanking: AnyObserver<Void>
    let replayButtonTapped: AnyObserver<Void>
    let toHomeButtonTapped: AnyObserver<Void>

    //output
    let rankingList: Observable<[Ranking]?>
    let backToTopPageWithReplay: Observable<Bool>
    
    //other
    private let disposeBag = DisposeBag()
    
    init() {
        
        //output
        let _rankingList = BehaviorRelay<[Ranking]?>(value: nil)
        self.rankingList = _rankingList.asObservable()
        
        let _backToTopPageWithReplay = PublishRelay<Bool>()
        self.backToTopPageWithReplay = _backToTopPageWithReplay.asObservable()
        
        //input
        self.getRanking = AnyObserver<Void>() { _ in
            _rankingList.accept(RankingRepository.getRanking())
        }
        
        self.replayButtonTapped = AnyObserver<Void>() { _ in
            _backToTopPageWithReplay.accept(true)
        }
        
        self.toHomeButtonTapped = AnyObserver<Void>() { _ in
            _backToTopPageWithReplay.accept(false)
        }
    }
    
}


