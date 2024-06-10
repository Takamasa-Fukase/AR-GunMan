//
//  RegisterNameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import RxSwift
import RxCocoa

final class NameRegisterEventObserver {
    let onRegister = PublishRelay<Ranking>()
    let onClose = PublishRelay<Void>()
}

final class NameRegisterViewModel: ViewModelType {
    struct Input {
        let viewWillDisappear: Observable<Void>
        let nameTextFieldChanged: Observable<String>
        let registerButtonTapped: Observable<Void>
        let noButtonTapped: Observable<Void>
    }
    
    struct Output {
        let rankText: Observable<String?>
        let scoreText: Observable<String>
        let isRegisterButtonEnabled: Observable<Bool>
        let isRegistering: Observable<Bool>
    }
    
    struct State {}
    
    private let navigator: NameRegisterNavigatorInterface
    private let useCase: NameRegisterUseCaseInterface
    private let score: Double
    private let rankingListObservable: Observable<[Ranking]>
    private weak var eventObserver: NameRegisterEventObserver?
    
    private let disposeBag = DisposeBag()
    
    init(
        navigator: NameRegisterNavigatorInterface,
        useCase: NameRegisterUseCaseInterface,
        score: Double,
        rankingListObservable: Observable<[Ranking]>,
        eventObserver: NameRegisterEventObserver?
    ) {
        self.navigator = navigator
        self.useCase = useCase
        self.score = score
        self.rankingListObservable = rankingListObservable
        self.eventObserver = eventObserver
    }
    
    func transform(input: Input) -> Output {
        let registeringTracker = ObservableActivityTracker()
        
        input.viewWillDisappear
            .bind(to: eventObserver?.onClose ?? PublishRelay())
            .disposed(by: disposeBag)
        
        input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .flatMapLatest({ [weak self] userName in
                let ranking = Ranking(score: self?.score ?? 0.0, userName: userName)
                return (self?.useCase.registerRanking(ranking) ?? Single.just(ranking))
                    .trackActivity(registeringTracker)
            })
            .subscribe(
                onNext: { [weak self] registeredRanking in
                    self?.eventObserver?.onRegister.accept(registeredRanking)
                    self?.navigator.dismiss()
                },
                onError: { [weak self] error in
                    self?.navigator.showErrorAlert(error)
                }
            ).disposed(by: disposeBag)
        
        input.noButtonTapped
            .subscribe(onNext: { [weak self] _ in
                self?.navigator.dismiss()
            }).disposed(by: disposeBag)
        
        let rankText = rankingListObservable
            .filter({ !$0.isEmpty })
            .map({ [weak self] rankingList in
                return RankingUtil.createTemporaryRankText(
                    rankingList: rankingList,
                    score: self?.score ?? 0.0
                )
            })
        
        let scoreText = Observable.just("Score: \(score.scoreText)")
        
        let isRegisterButtonEnabled = input.nameTextFieldChanged
            .map({ element in
                return !element.isEmpty
            })
        
        return Output(
            rankText: rankText,
            scoreText: scoreText,
            isRegisterButtonEnabled: isRegisterButtonEnabled,
            isRegistering: registeringTracker.asObservable()
        )
    }
}
