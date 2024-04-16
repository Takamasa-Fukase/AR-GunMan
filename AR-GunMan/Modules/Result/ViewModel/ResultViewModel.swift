//
//  ResultViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/1/23.
//

import RxSwift
import RxCocoa

class ResultViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let replayButtonTapped: Observable<Void>
        let toHomeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rankingList: Observable<[Ranking]>
        let totalScore: Observable<Double>
        let showNameRegisterView: Observable<NameRegisterViewModel.Dependency>
        let showButtons: Observable<Void>
        let scrollAndHightlightCell: Observable<IndexPath>
        let backToTopPageView: Observable<Void>
        let isLoading: Observable<Bool>
        let error: Observable<Error>
    }
    
    struct State {
        
    }
    
    private let rankingRepository: RankingRepository
    private let totalScore: Double
    
    private let disposeBag = DisposeBag()
    private let nameRegisterEventObserver = NameRegisterEventObserver()
    
    init(
        rankingRepository: RankingRepository,
        totalScore: Double
    ) {
        self.rankingRepository = rankingRepository
        self.totalScore = totalScore
    }
    
    func transform(input: Input) -> Output {
        let showButtonsRelay = PublishRelay<Void>()
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        let scrollAndHightlightCellRelay = PublishRelay<IndexPath>()
        let showNameRegisterViewRelay = PublishRelay<NameRegisterViewModel.Dependency>()
        let backToTopPageViewRelay = PublishRelay<Void>()
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        let errorRelay = PublishRelay<Error>()
        
        func fetchRanking() {
            Task { @MainActor in
                isLoadingRelay.accept(true)
                do {
                    let rankingList = try await rankingRepository.getRanking()
                    rankingListRelay.accept(rankingList)
                }catch {
                    errorRelay.accept(error)
                }
                isLoadingRelay.accept(false)
            }
        }
        
        func showNameRegisterDialog() {
            showNameRegisterViewRelay.accept(
                .init(
                    rankingRepository: rankingRepository,
                    totalScore: totalScore,
                    rankingListObservable: rankingListRelay.asObservable(),
                    observer: nameRegisterEventObserver
                )
            )
        }
        
        input.viewWillAppear
            .take(1)
            .subscribe(onNext: { _ in
                fetchRanking()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showNameRegisterDialog()
                }
            }).disposed(by: disposeBag)
        
        input.replayButtonTapped
            .subscribe(onNext: { _ in
                // TODO: あとでUseCaseのアクセスに差し替える
                let replayRepository = ReplayRepository()
                replayRepository.setNeedsReplay(true)
                backToTopPageViewRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        input.toHomeButtonTapped
            .subscribe(onNext: { _ in
                backToTopPageViewRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        nameRegisterEventObserver.onRegister
            .subscribe(onNext: { registeredRanking in
                let rankIndex = RankingUtil.getTemporaryRankIndex(
                    rankingList: rankingListRelay.value,
                    score: registeredRanking.score
                )
                var newRankingList = rankingListRelay.value
                // 登録したランキングが含まれたリストを作成して新しい値として流す
                newRankingList.insert(registeredRanking, at: rankIndex)
                rankingListRelay.accept(newRankingList)
                // 登録したランキングが中央に表示されるようにスクロール＆ハイライトさせる
                scrollAndHightlightCellRelay.accept(IndexPath(row: rankIndex, section: 0))
            }).disposed(by: disposeBag)

        return Output(
            rankingList: rankingListRelay.asObservable(),
            totalScore: Observable.just(totalScore),
            showNameRegisterView: showNameRegisterViewRelay.asObservable(),
            showButtons: nameRegisterEventObserver.onClose.asObservable(),
            scrollAndHightlightCell: scrollAndHightlightCellRelay.asObservable(),
            backToTopPageView: backToTopPageViewRelay.asObservable(),
            isLoading: isLoadingRelay.asObservable(),
            error: errorRelay.asObservable()
        )
    }
}
