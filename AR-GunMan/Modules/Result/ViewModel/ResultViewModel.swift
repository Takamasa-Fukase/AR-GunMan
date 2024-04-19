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

    private let useCase: ResultUseCase
    private let navigator: ResultNavigatorInterface
    private let totalScore: Double
    
    private let disposeBag = DisposeBag()
    private let nameRegisterEventObserver = NameRegisterEventObserver()
    
    init(
        useCase: ResultUseCase,
        navigator: ResultNavigatorInterface,
        totalScore: Double
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.totalScore = totalScore
    }
    
    func transform(input: Input) -> Output {
        let rankingListRelay = BehaviorRelay<[Ranking]>(value: [])
        let scrollAndHightlightCellRelay = PublishRelay<IndexPath>()
        let loadingTracker = ObservableActivityTracker()

        input.viewWillAppear
            .take(1)
            .map({ [weak self] _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.navigator.showNameRegister(
                        totalScore: self?.totalScore ?? 0.0,
                        rankingListObservable: rankingListRelay.asObservable(),
                        eventObserver: self?.nameRegisterEventObserver ?? NameRegisterEventObserver()
                    )
                }
            })
            .flatMapLatest({ [weak self] in
                return (self?.useCase.getRanking() ?? Single.just([]))
                    .trackActivity(loadingTracker)
            })
            .subscribe(onNext: { ranking in
                rankingListRelay.accept(ranking)
            }, onError: { [weak self] error in
                self?.navigator.showErrorAlert(error)
            }).disposed(by: disposeBag)
        
        input.replayButtonTapped
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.useCase.setNeedsReplay(true)
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
            isLoading: loadingTracker.asObservable()
        )
    }
}
