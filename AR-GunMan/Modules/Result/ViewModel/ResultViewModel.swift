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
        let showButtons: Observable<Void>
        let scrollAndHightlightCell: Observable<IndexPath>
        let isLoading: Observable<Bool>
    }
    
    struct State {
        
    }
    
    private let navigator: ResultNavigatorInterface
    private let rankingRepository: RankingRepository
    private let totalScore: Double
    
    private let disposeBag = DisposeBag()
    private let nameRegisterEventObserver = NameRegisterEventObserver()
    
    init(
        navigator: ResultNavigatorInterface,
        rankingRepository: RankingRepository,
        totalScore: Double
    ) {
        self.navigator = navigator
        self.rankingRepository = rankingRepository
        self.totalScore = totalScore
    }
    
    func transform(input: Input) -> Output {
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        let scrollAndHightlightCellRelay = PublishRelay<IndexPath>()
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        
        func fetchRanking() {
            Task { @MainActor in
                isLoadingRelay.accept(true)
                do {
                    let rankingList = try await rankingRepository.getRanking()
                    rankingListRelay.accept(rankingList)
                }catch {
                    navigator.showErrorAlert(error)
                }
                isLoadingRelay.accept(false)
            }
        }
        
        input.viewWillAppear
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                fetchRanking()
                let vmDependency = NameRegisterViewModel.Dependency(
                    rankingRepository: rankingRepository,
                    totalScore: totalScore,
                    rankingListObservable: rankingListRelay.asObservable(),
                    observer: nameRegisterEventObserver
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.navigator.showNameRegister(vmDependency: vmDependency)
                }
            }).disposed(by: disposeBag)
        
        input.replayButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                // TODO: あとでUseCaseのアクセスに差し替える
                let replayRepository = ReplayRepository()
                replayRepository.setNeedsReplay(true)
                self.navigator.backToTop()
            }).disposed(by: disposeBag)
        
        input.toHomeButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.backToTop()
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
            showButtons: nameRegisterEventObserver.onClose.asObservable(),
            scrollAndHightlightCell: scrollAndHightlightCellRelay.asObservable(),
            isLoading: isLoadingRelay.asObservable()
        )
    }
}
