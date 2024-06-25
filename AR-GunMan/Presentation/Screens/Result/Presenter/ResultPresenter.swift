//
//  ResultPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

struct ResultControllerInput {
    let viewWillAppear: Observable<Void>
    let replayButtonTapped: Observable<Void>
    let toHomeButtonTapped: Observable<Void>
}

struct ResultViewModel {
    let rankingList: Observable<[Ranking]>
    let scoreText: Observable<String>
    let showButtons: Observable<Void>
    let scrollCellToCenter: Observable<IndexPath>
    let isLoadingRankingList: Observable<Bool>
}

protocol ResultPresenterInterface {
    func transform(input: ResultControllerInput) -> ResultViewModel
}

final class ResultPresenter: ResultPresenterInterface {
    private let rankingRepository: RankingRepositoryInterface
    private let replayRepository: ReplayRepositoryInterface
    private let navigator: ResultNavigatorInterface
    private let score: Double
    
    // 遷移先からの通知を受け取るレシーバー
    private let nameRegisterEventReceiver: NameRegisterEventReceiver
    
    private let disposeBag = DisposeBag()
    
    init(
        rankingRepository: RankingRepositoryInterface,
        replayRepository: ReplayRepositoryInterface,
        navigator: ResultNavigatorInterface,
        score: Double,
        nameRegisterEventReceiver: NameRegisterEventReceiver = NameRegisterEventReceiver()
    ) {
        self.rankingRepository = rankingRepository
        self.replayRepository = replayRepository
        self.navigator = navigator
        self.score = score
        self.nameRegisterEventReceiver = nameRegisterEventReceiver
    }
    
    func transform(input: ResultControllerInput) -> ResultViewModel {
        let rankingLoadActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        let temporaryRankTextRelay = BehaviorRelay<String>(value: "")
        
        let loadedRankingList = input.viewWillAppear
            .take(1)
            .flatMapLatest({ [weak self] _ -> Observable<[Ranking]> in
                guard let self = self else { return .empty() }
                return self.rankingRepository.getRanking()
                    .trackActivity(rankingLoadActivityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
            })
            .share()
        
        let temporaryRankIndex = loadedRankingList
            .map({ [weak self] in
                guard let self = self else { return 0 }
                return RankingUtil.getTemporaryRankIndex(
                    rankingList: $0,
                    score: self.score
                )
            })
            .share()
        
        let updatedRankingListAfterRegister = nameRegisterEventReceiver.onRegisterComplete
            .withLatestFrom(Observable.combineLatest(
                loadedRankingList,
                temporaryRankIndex
            )) {
                return (registeredRanking: $0, rankingList: $1.0, rankIndex: $1.1)
            }
            .map({
                var updatedRankingList = $0.rankingList
                // 登録したランキングが含まれたリストを作成
                updatedRankingList.insert($0.registeredRanking, at: $0.rankIndex)
                return updatedRankingList
            })
        
        disposeBag.insert {
            temporaryRankIndex
                .withLatestFrom(loadedRankingList) { (rankIndex: $0, rankingList: $1) }
                .map({
                    return RankingUtil.createTemporaryRankText(
                        temporaryRankIndex: $0.rankIndex,
                        rankingListCount: $0.rankingList.count
                    )
                })
                .bind(to: temporaryRankTextRelay)
            input.viewWillAppear
                .take(1)
                .flatMapLatest({ _ in
                    return TimerStreamCreator
                        .create(
                            milliSec: ResultConst.showNameRegisterWaitingTimeMillisec,
                            isRepeated: false
                        )
                        .mapToVoid()
                })
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.showNameRegister(
                        score: self.score,
                        temporaryRankTextObservable: temporaryRankTextRelay.asObservable(),
                        eventReceiver: self.nameRegisterEventReceiver
                    )
                })
            Observable
                .merge(
                    input.replayButtonTapped
                        .flatMapLatest({ [weak self] _ -> Observable<Void> in
                            guard let self = self else { return .empty() }
                            return self.replayRepository.setNeedsReplay(true)
                        }),
                    input.toHomeButtonTapped
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.backToTop()
                })
            errorTracker.asObservable()
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.navigator.showErrorAlert($0)
                })
        }
        
        let rankingList = Observable
            .merge(
                loadedRankingList,
                updatedRankingListAfterRegister
            )
        
        let scrollCellToCenter = nameRegisterEventReceiver.onRegisterComplete
            .withLatestFrom(temporaryRankIndex)
            .map({ IndexPath(row: $0, section: 0) })
                
        return ResultViewModel(
            rankingList: rankingList,
            scoreText: Observable.just(score.scoreText),
            showButtons: nameRegisterEventReceiver.onClose.asObservable(),
            scrollCellToCenter: scrollCellToCenter,
            isLoadingRankingList: rankingLoadActivityTracker.asObservable()
        )
    }
}
