//
//  RankingPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

struct RankingControllerInput {
    let viewWillAppear: Observable<Void>
    let closeButtonTapped: Observable<Void>
    let backgroundViewTapped: Observable<Void>
}

struct RankingViewModel {
    let rankingList: Driver<[Ranking]>
    let isLoadingRankingList: Driver<Bool>
}

protocol RankingPresenterInterface {
    func transform(input: RankingControllerInput) -> RankingViewModel
}

final class RankingPresenter: RankingPresenterInterface {
    private let getRankingUseCase: GetRankingUseCaseInterface
    private let navigator: RankingNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(
        getRankingUseCase: GetRankingUseCaseInterface,
        navigator: RankingNavigatorInterface
    ) {
        self.getRankingUseCase = getRankingUseCase
        self.navigator = navigator
    }

    func transform(input: RankingControllerInput) -> RankingViewModel {
        let rankingLoadActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        
        disposeBag.insert {
            // MARK: Transitions
            Observable
                .merge(
                    input.closeButtonTapped,
                    input.backgroundViewTapped
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.dismiss()
                })
            errorTracker.asObservable()
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.navigator.showErrorAlert($0)
                })
        }
        
        let rankingList = input.viewWillAppear
            .take(1)
            .flatMapLatest({ [weak self] _ -> Observable<[Ranking]> in
                guard let self = self else { return .empty() }
                return self.getRankingUseCase.execute()
                    .rankingList
                    .trackActivity(rankingLoadActivityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
            })
        
        return RankingViewModel(
            rankingList: rankingList
                .asDriverOnErrorJustComplete(),
            isLoadingRankingList: rankingLoadActivityTracker.asObservable()
                .asDriverOnErrorJustComplete()
        )
    }
}
