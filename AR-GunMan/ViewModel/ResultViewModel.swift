//
//  ResultViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/1/23.
//

import RxSwift
import RxCocoa

class ResultViewModel {
    let rankingList: Observable<[Ranking]>
    let totalScoreText: Observable<String>
    let showNameRegisterView: Observable<NameRegisterViewModel.Dependency>
    var showButtons: Observable<Void> {
        return showButtonsRelay.asObservable()
    }
    let backToTopPageView: Observable<Void>
    let isLoading: Observable<Bool>
    let error: Observable<Error>
    
    private let showButtonsRelay = PublishRelay<Void>()
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
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        self.rankingList = rankingListRelay.asObservable()
        
        self.totalScoreText = Observable.just(
            String(format: "%.3f", dependency.totalScore)
        )
        
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
            }).disposed(by: disposeBag)
        
        input.replayButtonTapped
            .subscribe(onNext: { _ in
                UserDefaults.isReplay = true
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
                    rankingListRelay.accept(rankingList)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showNameRegisterViewRelay.accept(
                            createNameRegisterViewModelDependency()
                        )
                    }
                }catch {
                    errorRelay.accept(error)
                }
                isLoadingRelay.accept(false)
            }
        }

        @Sendable
        func createNameRegisterViewModelDependency() -> NameRegisterViewModel.Dependency {
            let threeDigitsScore = Double(round(1000 * dependency.totalScore) / 1000)
            let limitRankIndex = rankingListRelay.value.firstIndex(where: {
                $0.score < threeDigitsScore
            }) ?? 0
            return .init(
                totalScore: dependency.totalScore,
                // TODO: - この+2の意味を思い出して再度確認する
                tentativeRank: limitRankIndex + 2,
                rankingLength: rankingListRelay.value.count,
                threeDigitsScore: threeDigitsScore,
                delegate: self,
                rankingRepository: RankingRepository())
        }
    }
}

extension ResultViewModel: NameRegisterDelegate {
    func showRightButtons() {
        showButtonsRelay.accept(Void())
    }
}



