//
//  RankingViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

class RankingViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let closeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rankingList: Observable<[Ranking]>
        let dismiss: Observable<Void>
        let isLoading: Observable<Bool>
        let error: Observable<Error>
    }
    
    struct State {}
    
    private let rankingRepository: RankingRepository
    private let disposeBag = DisposeBag()
    
    init(
        rankingRepository: RankingRepository
    ) {
        self.rankingRepository = rankingRepository
    }

    func transform(input: Input) -> Output {
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<Error>()

        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
                    isLoadingRelay.accept(true)
                    do {
                        let rankingList = try await self.rankingRepository.getRanking()
                        rankingListRelay.accept(rankingList)
                    } catch {
                        errorRelay.accept(error)
                    }
                    isLoadingRelay.accept(false)
                }
            }).disposed(by: disposeBag)
        
        return Output(
            rankingList: rankingListRelay.asObservable(),
            dismiss: input.closeButtonTapped,
            isLoading: isLoadingRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
}


