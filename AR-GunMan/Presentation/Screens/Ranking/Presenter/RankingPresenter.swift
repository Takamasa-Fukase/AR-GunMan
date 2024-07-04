//
//  RankingPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2/7/24.
//

import RxSwift
import RxCocoa

final class RankingPresenter: PresenterType {
    struct ControllerEvents {
        let viewWillAppear: Observable<Void>
        let closeButtonTapped: Observable<Void>
        let backgroundViewTapped: Observable<Void>
    }
    struct ViewModel {
        let rankingList: Driver<[RankingListItemModel]>
        let isLoadingRankingList: Driver<Bool>
    }
    
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

    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        let rankingLoadActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        
        let rankingList = input.viewWillAppear
            .take(1)
            .flatMapLatest({ [weak self] _ -> Observable<[RankingListItemModel]> in
                guard let self = self else { return .empty() }
                return self.getRankingUseCase
                    .execute()
                    .rankingList
                    .trackActivity(rankingLoadActivityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
            })
        
        disposeBag.insert {
            // MARK: 画面遷移
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
        
        return ViewModel(
            rankingList: rankingList
                .asDriverOnErrorJustComplete(),
            isLoadingRankingList: rankingLoadActivityTracker.asObservable()
                .asDriverOnErrorJustComplete()
        )
    }
}
