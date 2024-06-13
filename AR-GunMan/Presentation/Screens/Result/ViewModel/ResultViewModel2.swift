//
//  ResultViewModel2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 12/6/24.
//

import RxSwift
import RxCocoa

final class ResultViewModel2: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let replayButtonTapped: Observable<Void>
        let toHomeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
                
        struct ViewModelAction {
            let rankingListFetched: Observable<[Ranking]>
            let nameRegisterViewShowed: Observable<Void>
            let rankingListUpdatedAfterRegister: Observable<[Ranking]>
            let viewDismissedToTopPage: Observable<Void>
            let errorAlertShowed: Observable<Error>
            let needsReplayFlagIsSetToTrue: Observable<Void>
        }
        
        struct OutputToView {
            let rankingList: Observable<[Ranking]>
            let scoreText: Observable<String>
            let showButtons: Observable<Void>
            let scrollCellToCenter: Observable<IndexPath>
            let isLoadingRankingList: Observable<Bool>
        }
    }
    
    struct State {}

    private let useCase: ResultUseCaseInterface
    private let navigator: ResultNavigatorInterface
    private let score: Double
    
    // 遷移先からの通知を受け取るレシーバー
    private let nameRegisterEventReceiver: NameRegisterEventReceiver2
    
    init(
        useCase: ResultUseCaseInterface,
        navigator: ResultNavigatorInterface,
        score: Double,
        nameRegisterEventReceiver: NameRegisterEventReceiver2 = NameRegisterEventReceiver2()
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.score = score
        self.nameRegisterEventReceiver = nameRegisterEventReceiver
    }
    
    func transform(input: Input) -> Output {
        let rankingLoadActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()

        // MARK: - ViewModelAction
        let fetchedRankingList = input.viewWillAppear
            .take(1)
            .flatMapLatest({ [weak self] _ -> Observable<[Ranking]> in
                guard let self = self else { return .empty() }
                return self.useCase.getRanking()
                    .trackActivity(rankingLoadActivityTracker)
                    .trackError(errorTracker)
            })
        
        let temporaryRankIndex = fetchedRankingList
            .map({ [weak self] in
                guard let self = self else { return 0 }
                return RankingUtil.getTemporaryRankIndex(
                    rankingList: $0,
                    score: self.score
                )
            })
        
        let temporaryRankText = temporaryRankIndex
            .withLatestFrom(fetchedRankingList) { (rankIndex: $0, rankingList: $1) }
            .map({
                return RankingUtil.createTemporaryRankText2(
                    temporaryRankIndex: $0.rankIndex,
                    rankingListCount: $0.rankingList.count
                )
            })
        
        let nameRegisterViewShowed = input.viewWillAppear
            .take(1)
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.useCase.awaitShowNameRegisterSignal()
            })
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.showNameRegister2(
                    score: self.score,
                    temporaryRankTextObservable: temporaryRankText,
                    eventReceiver: self.nameRegisterEventReceiver
                )
            })
        
        let updatedRankingListAfterRegister = nameRegisterEventReceiver.onRegisterComplete
            .withLatestFrom(Observable.combineLatest(
                fetchedRankingList,
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
        
        let viewDismissedToTopPage = Observable
            .merge(
                input.replayButtonTapped,
                input.toHomeButtonTapped
            )
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.backToTop()
            })
        
        let errorAlertShowed = errorTracker.asObservable()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigator.showErrorAlert($0)
            })
        
        let needsReplayFlagIsSetToTrue = input.replayButtonTapped
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.useCase.setNeedsReplay(true)
            })
        
        
        // MARK: - OutputToView
        let rankingList = Observable
            .merge(
                fetchedRankingList,
                updatedRankingListAfterRegister
            )
        
        let scoreText = Observable.just(score.scoreText)
        
        let showButtons = nameRegisterEventReceiver.onClose.asObservable()
        
        let scrollCellToCenter = nameRegisterEventReceiver.onRegisterComplete
            .withLatestFrom(temporaryRankIndex)
            .map({ IndexPath(row: $0, section: 0) })
        
        let isLoadingRankingList = rankingLoadActivityTracker.asObservable()
        
        
        return Output(
            viewModelAction: Output.ViewModelAction(
                rankingListFetched: fetchedRankingList,
                nameRegisterViewShowed: nameRegisterViewShowed,
                rankingListUpdatedAfterRegister: updatedRankingListAfterRegister,
                viewDismissedToTopPage: viewDismissedToTopPage,
                errorAlertShowed: errorAlertShowed,
                needsReplayFlagIsSetToTrue: needsReplayFlagIsSetToTrue
            ),
            outputToView: Output.OutputToView(
                rankingList: rankingList,
                scoreText: scoreText,
                showButtons: showButtons,
                scrollCellToCenter: scrollCellToCenter,
                isLoadingRankingList: isLoadingRankingList
            )
        )
    }
}
