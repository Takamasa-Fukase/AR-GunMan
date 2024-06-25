//
//  NameRegisterPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

final class NameRegisterEventReceiver {
    let onRegisterComplete = PublishRelay<Ranking>()
    let onClose = PublishRelay<Void>()
}

struct NameRegisterControllerInput {
    let viewWillDisappear: Observable<Void>
    let nameTextFieldChanged: Observable<String>
    let registerButtonTapped: Observable<Void>
    let noButtonTapped: Observable<Void>
    let backgroundViewTapped: Observable<Void>
    let keyboardWillShowNotificationReceived: Observable<Notification>
    let keyboardWillHideNotificationReceived: Observable<Notification>
}

struct NameRegisterViewModel {
    let temporaryRankText: Observable<String>
    let scoreText: Observable<String>
    let isRegisterButtonEnabled: Observable<Bool>
    let isRegistering: Observable<Bool>
    let handleActiveTextFieldOverlapWhenKeyboardWillShow: Observable<Notification>
    let resetActiveTextFieldPositionWhenKeyboardWillHide: Observable<Notification>
}

protocol NameRegisterPresenterInterface {
    func transform(input: NameRegisterControllerInput) -> NameRegisterViewModel
}

final class NameRegisterPresenter: NameRegisterPresenterInterface {
    private let rankingRepository: RankingRepositoryInterface
    private let navigator: NameRegisterNavigatorInterface
    private let score: Double
    private let temporaryRankTextObservable: Observable<String>
    private weak var eventReceiver: NameRegisterEventReceiver?
    private let disposeBag = DisposeBag()

    init(
        rankingRepository: RankingRepositoryInterface,
        navigator: NameRegisterNavigatorInterface,
        score: Double,
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver?
    ) {
        self.rankingRepository = rankingRepository
        self.navigator = navigator
        self.score = score
        self.temporaryRankTextObservable = temporaryRankTextObservable
        self.eventReceiver = eventReceiver
    }
    
    func transform(input: NameRegisterControllerInput) -> NameRegisterViewModel {
        let registerActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        
        let rankingRegistered = input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .flatMapLatest({ [weak self] userName -> Observable<Ranking> in
                guard let self = self else { return .empty() }
                let ranking = Ranking(score: self.score, userName: userName)
                return self.rankingRepository.registerRanking(ranking)
                    .trackActivity(registerActivityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
            })
            .share()
        
        disposeBag.insert {
            // MARK: Event posts
            input.viewWillDisappear
                .bind(to: eventReceiver?.onClose ?? PublishRelay<Void>())
            rankingRegistered
                .bind(to: eventReceiver?.onRegisterComplete ?? PublishRelay<Ranking>())
            
            // MARK: Transitions
            Observable
                .merge(
                    input.noButtonTapped,
                    input.backgroundViewTapped,
                    rankingRegistered.mapToVoid()
                )
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.navigator.dismiss()
                })
            errorTracker.asObservable()
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.navigator.showErrorAlert($0)
                })
        }
        
        return NameRegisterViewModel(
            temporaryRankText: temporaryRankTextObservable,
            scoreText: Observable.just("Score: \(score.scoreText)"),
            isRegisterButtonEnabled: input.nameTextFieldChanged.map({ !$0.isEmpty }),
            isRegistering: registerActivityTracker.asObservable(),
            handleActiveTextFieldOverlapWhenKeyboardWillShow: input.keyboardWillShowNotificationReceived,
            resetActiveTextFieldPositionWhenKeyboardWillHide: input.keyboardWillHideNotificationReceived
        )
    }
}
