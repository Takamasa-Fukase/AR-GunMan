//
//  ResultViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/1/23.
//

import RxSwift
import RxCocoa

class ResultViewModel {
    var rankingList: Observable<[Ranking]> {
        return rankingListRelay.asObservable()
    }
    let totalScore: Observable<Double>
    let showNameRegisterView: Observable<NameRegisterViewModel.Dependency>
    var showButtons: Observable<Void> {
        return showButtonsRelay.asObservable()
    }
    var scrollAndHightlightCell: Observable<IndexPath> {
        return scrollAndHightlightCellRelay.asObservable()
    }
    let backToTopPageView: Observable<Void>
    let isLoading: Observable<Bool>
    let error: Observable<Error>
    
    private let showButtonsRelay = PublishRelay<Void>()
    private let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
    private let scrollAndHightlightCellRelay = PublishRelay<IndexPath>()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let replayButtonTapped: Observable<Void>
        let toHomeButtonTapped: Observable<Void>
    }
    
    struct Dependency {
        let rankingRepository: RankingRepository
        let totalScore: Double
    }
    
    init(input: Input,
         dependency: Dependency) {
        self.totalScore = Observable.just(dependency.totalScore)
        
        let showNameRegisterViewRelay = PublishRelay<NameRegisterViewModel.Dependency>()
        self.showNameRegisterView = showNameRegisterViewRelay.asObservable()
        
        let backToTopPageViewRelay = PublishRelay<Void>()
        self.backToTopPageView = backToTopPageViewRelay.asObservable()
        
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        self.isLoading = isLoadingRelay.asObservable()
        
        let errorRelay = PublishRelay<Error>()
        self.error = errorRelay.asObservable()
        
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
        
        func fetchRanking() {
            Task { @MainActor in
                isLoadingRelay.accept(true)
                do {
                    let rankingList = try await dependency.rankingRepository.getRanking()
                    self.rankingListRelay.accept(rankingList)
                }catch {
                    errorRelay.accept(error)
                }
                isLoadingRelay.accept(false)
            }
        }
        
        func showNameRegisterDialog() {
            showNameRegisterViewRelay.accept(
                .init(
                    rankingRepository: RankingRepository(),
                    totalScore: dependency.totalScore,
                    rankingListObservable: self.rankingList,
                    delegate: self
                )
            )
        }
    }
}

extension ResultViewModel: NameRegisterDelegate {
    func onRegistered(registeredRanking: Ranking) {
        let rankIndex = RankingUtil.getTemporaryRankIndex(
            rankingList: self.rankingListRelay.value,
            score: registeredRanking.score
        )
        var newRankingList = self.rankingListRelay.value
        // 登録したランキングが含まれたリストを作成して新しい値として流す
        newRankingList.insert(registeredRanking, at: rankIndex)
        self.rankingListRelay.accept(newRankingList)
        // 登録したランキングが中央に表示されるようにスクロール＆ハイライトさせる
        scrollAndHightlightCellRelay.accept(IndexPath(row: rankIndex, section: 0))
    }
    
    func onClose() {
        showButtonsRelay.accept(Void())
    }
}



