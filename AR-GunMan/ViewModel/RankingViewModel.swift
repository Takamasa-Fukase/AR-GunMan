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
    let rankingList: Observable<[Ranking]>
    let dismiss: Observable<Void>
    let isLoading: Observable<Bool>
    let error: Observable<Error>
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let closeButtonTapped: Observable<Void>
    }
    
    init(input: Input,
         dependency rankingRepository: RankingRepository) {        
        //output
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        self.rankingList = rankingListRelay.asObservable()
        
        let dismissRelay = PublishRelay<Void>()
        self.dismiss = dismissRelay.asObservable()
        
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        self.isLoading = isLoadingRelay.asObservable()
        
        let errorRelay = PublishRelay<Error>()
        self.error = errorRelay.asObservable()

        input.viewWillAppear
            .subscribe(onNext: { _ in
                Task { @MainActor in
                    isLoadingRelay.accept(true)
                    do {
                        let rankingList = try await rankingRepository.getRanking()
                        rankingListRelay.accept(rankingList)
                    } catch {
                        errorRelay.accept(error)
                    }
                    isLoadingRelay.accept(false)
                }
            }).disposed(by: disposeBag)
        
        input.closeButtonTapped
            .bind(to: dismissRelay)
            .disposed(by: disposeBag)
    }
    
}


