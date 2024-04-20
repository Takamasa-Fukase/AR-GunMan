//
//  RegisterNameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import RxSwift
import RxCocoa

class NameRegisterEventObserver {
    let onRegister = PublishRelay<Ranking>()
    let onClose = PublishRelay<Void>()
}

class NameRegisterViewModel: ViewModelType {
    struct Input {
        let viewWillDisappear: Observable<Void>
        let nameTextFieldChanged: Observable<String>
        let registerButtonTapped: Observable<Void>
        let noButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rankText: Observable<String?>
        let totalScore: Observable<String>
        let isRegisterButtonEnabled: Observable<Bool>
        let dismiss: Observable<Void>
        let isRegistering: Observable<Bool>
    }
    
    struct State {}
    
    private let rankingRepository: RankingRepository
    private let totalScore: Double
    private let rankingListObservable: Observable<[Ranking]>
    private weak var eventObserver: NameRegisterEventObserver?
    
    private let disposeBag = DisposeBag()
    
    init(
        rankingRepository: RankingRepository,
        totalScore: Double,
        rankingListObservable: Observable<[Ranking]>,
        eventObserver: NameRegisterEventObserver?
    ) {
        self.rankingRepository = rankingRepository
        self.totalScore = totalScore
        self.rankingListObservable = rankingListObservable
        self.eventObserver = eventObserver
    }
    
    func transform(input: Input) -> Output {
        let dismissRelay = PublishRelay<Void>()
        let registeringTracker = ObservableActivityTracker()
        
        input.viewWillDisappear
            .bind(to: eventObserver?.onClose ?? PublishRelay())
            .disposed(by: disposeBag)
        
        input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .flatMapLatest({ [weak self] userName in
                let ranking = Ranking(score: self?.totalScore ?? 0.0, userName: userName)
                return (self?.rankingRepository.registerRanking2(ranking) ?? Single.just(ranking))
                    .trackActivity(registeringTracker)
            })
            .subscribe(
                onNext: { [weak self] registeredRanking in
                    self?.eventObserver?.onRegister.accept(registeredRanking)
                    dismissRelay.accept(Void())
                },
                onError: { [weak self] error in
                    // TODO: navigator経由でエラーアラートを表示
                }
            ).disposed(by: disposeBag)
        
        input.noButtonTapped
            .subscribe(onNext: { _ in
                dismissRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        let rankText = rankingListObservable
            .filter({ !$0.isEmpty })
            .map({ [weak self] rankingList in
                return RankingUtil.createTemporaryRankText(
                    rankingList: rankingList,
                    score: self?.totalScore ?? 0.0
                )
            })
        
        let totalScore = Observable.just(
            "Score: \(String(format: "%.3f", totalScore))"
        )
        
        let isRegisterButtonEnabled = input.nameTextFieldChanged
            .map({ element in
                return !element.isEmpty
            })
        
        return Output(
            rankText: rankText,
            totalScore: totalScore,
            isRegisterButtonEnabled: isRegisterButtonEnabled,
            dismiss: dismissRelay.asObservable(),
            isRegistering: registeringTracker.asObservable()
        )
    }
}
