//
//  ResultPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

final class ResultPresenter: PresenterType {
    struct ControllerEvents {
        let viewWillAppear: Observable<Void>
        let replayButtonTapped: Observable<Void>
        let toHomeButtonTapped: Observable<Void>
    }
    struct ViewModel {
        let rankingList: Driver<[RankingListItemModel]>
        let scoreText: Driver<String>
        let showButtons: Driver<Void>
        let scrollCellToCenter: Driver<IndexPath>
        let isLoadingRankingList: Driver<Bool>
    }
    
    private let replayRepository: ReplayRepositoryInterface
    private let getRankingUseCase: GetRankingUseCaseInterface
    private let timerStreamCreator: TimerStreamCreator
    private let navigator: ResultNavigatorInterface
    private let score: Double
    private let nameRegisterEventReceiver: NameRegisterEventReceiver
    private let disposeBag = DisposeBag()
    
    init(
        replayRepository: ReplayRepositoryInterface,
        getRankingUseCase: GetRankingUseCaseInterface,
        timerStreamCreator: TimerStreamCreator = TimerStreamCreator(),
        navigator: ResultNavigatorInterface,
        score: Double,
        nameRegisterEventReceiver: NameRegisterEventReceiver = NameRegisterEventReceiver()
    ) {
        self.replayRepository = replayRepository
        self.getRankingUseCase = getRankingUseCase
        self.timerStreamCreator = timerStreamCreator
        self.navigator = navigator
        self.score = score
        self.nameRegisterEventReceiver = nameRegisterEventReceiver
    }
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        let rankingLoadActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        let temporaryRankTextRelay = BehaviorRelay<String>(value: "")
        
        let loadedRankingList = input.viewWillAppear
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
            // MARK: レシーバーにイベントを通知
            temporaryRankIndex
                .withLatestFrom(loadedRankingList) { (rankIndex: $0, rankingList: $1) }
                .map({
                    return RankingUtil.createTemporaryRankText(
                        temporaryRankIndex: $0.rankIndex,
                        rankingListCount: $0.rankingList.count
                    )
                })
                .bind(to: temporaryRankTextRelay)
            
            // MARK: 画面遷移
            input.viewWillAppear
                .take(1)
                .flatMapLatest({ [weak self] _ -> Observable<Void> in
                    guard let self = self else { return .empty() }
                    return self.timerStreamCreator
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
                
        return ViewModel(
            rankingList: rankingList
                .asDriverOnErrorJustComplete(),
            scoreText: Observable.just(score.scoreText)
                .asDriverOnErrorJustComplete(),
            showButtons: nameRegisterEventReceiver.onClose.asObservable()
                .asDriverOnErrorJustComplete(),
            scrollCellToCenter: scrollCellToCenter
                .asDriverOnErrorJustComplete(),
            isLoadingRankingList: rankingLoadActivityTracker.asObservable()
                .asDriverOnErrorJustComplete()
        )
    }
}
