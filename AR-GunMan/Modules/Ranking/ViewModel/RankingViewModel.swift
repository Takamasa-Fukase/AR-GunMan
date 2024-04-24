//
//  RankingViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import Foundation
import RxSwift
import RxCocoa

final class RankingViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let closeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rankingList: Observable<[Ranking]>
        let isLoading: Observable<Bool>
    }
    
    struct State {}
    
    private let useCase: RankingUseCaseInterface
    private let navigator: RankingNavigatorInterface
    private let disposeBag = DisposeBag()
    
    init(
        useCase: RankingUseCaseInterface,
        navigator: RankingNavigatorInterface
    ) {
        self.useCase = useCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        let loadingTracker = ObservableActivityTracker()

        input.viewWillAppear
            .flatMapLatest({ [weak self] in
                return (self?.useCase.getRanking() ?? Single.just([]))
                    .trackActivity(loadingTracker)
            })
            .subscribe(
                onNext: { ranking in
                    rankingListRelay.accept(ranking)
                },
                onError: { [weak self] error in
                    self?.navigator.showErrorAlert(error)
                }
            ).disposed(by: disposeBag)

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


