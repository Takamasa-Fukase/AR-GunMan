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
        let isLoading: Observable<Bool>
    }
    
    struct State {}
    
    private let rankingRepository: RankingRepository
    private let navigator: RankingNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(
        rankingRepository: RankingRepository,
        navigator: RankingNavigatorInterface
    ) {
        self.rankingRepository = rankingRepository
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        let loadingTracker = ObservableActivityTracker()

        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                Task { @MainActor in
//                    isLoadingRelay.accept(true)
                    do {
                        let rankingList = try await self.rankingRepository.getRanking()
                        rankingListRelay.accept(rankingList)
                    } catch {
//                        errorRelay.accept(error)
                    }
//                    isLoadingRelay.accept(false)
                }
            }).disposed(by: disposeBag)
        
        input.closeButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            }).disposed(by: disposeBag)
        
        return Output(
            rankingList: rankingListRelay.asObservable(),
            isLoading: loadingTracker.asObservable()
        )
    }
}


