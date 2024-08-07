//
//  NameRegisterPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

import RxSwift
import RxCocoa

final class NameRegisterEventReceiver {
    let onRegisterComplete = PublishRelay<RankingListItemModel>()
    let onClose = PublishRelay<Void>()
}

final class NameRegisterPresenter: PresenterType {
    struct ControllerEvents {
        let viewWillDisappear: Observable<Void>
        let nameTextFieldChanged: Observable<String>
        let registerButtonTapped: Observable<Void>
        let noButtonTapped: Observable<Void>
        let backgroundViewTapped: Observable<Void>
        let keyboardWillShowNotificationReceived: Observable<Notification>
        let keyboardWillHideNotificationReceived: Observable<Notification>
    }
    struct ViewModel {
        let temporaryRankText: Driver<String>
        let scoreText: Driver<String>
        let isRegisterButtonEnabled: Driver<Bool>
        let isRegistering: Driver<Bool>
        let handleActiveTextFieldOverlapWhenKeyboardWillShow: Driver<Notification>
        let resetActiveTextFieldPositionWhenKeyboardWillHide: Driver<Notification>
    }
    
    private let registerRankingUseCase: RegisterRankingUseCaseInterface
    private let navigator: NameRegisterNavigatorInterface
    private let score: Double
    private let temporaryRankTextObservable: Observable<String>
    private weak var eventReceiver: NameRegisterEventReceiver?
    private let disposeBag = DisposeBag()

    init(
        registerRankingUseCase: RegisterRankingUseCaseInterface,
        navigator: NameRegisterNavigatorInterface,
        score: Double,
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver?
    ) {
        self.registerRankingUseCase = registerRankingUseCase
        self.navigator = navigator
        self.score = score
        self.temporaryRankTextObservable = temporaryRankTextObservable
        self.eventReceiver = eventReceiver
    }
    
    func generateViewModel(from input: ControllerEvents) -> ViewModel {
        let registerActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        
        let rankingRegistered = input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .flatMapLatest({ [weak self] userName -> Observable<RankingListItemModel> in
                guard let self = self else { return .empty() }
                let ranking = RankingListItemModel(score: self.score, userName: userName)
                return self.registerRankingUseCase
                    .generateOutput(from: .init(ranking: ranking))
                    .registered
                    .map({ _ in ranking })
                    .trackActivity(registerActivityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
            })
            .share()
        
        disposeBag.insert {
            // MARK: レシーバーにイベントを通知
            input.viewWillDisappear
                .bind(to: eventReceiver?.onClose ?? PublishRelay<Void>())
            rankingRegistered
                .bind(to: eventReceiver?.onRegisterComplete ?? PublishRelay<RankingListItemModel>())
            
            // MARK: 画面遷移
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
        
        return ViewModel(
            temporaryRankText: temporaryRankTextObservable
                .asDriverOnErrorJustComplete(),
            scoreText: Observable.just("Score: \(score.scoreText)")
                .asDriverOnErrorJustComplete(),
            isRegisterButtonEnabled: input.nameTextFieldChanged.map({ !$0.isEmpty })
                .asDriverOnErrorJustComplete(),
            isRegistering: registerActivityTracker.asObservable()
                .asDriverOnErrorJustComplete(),
            handleActiveTextFieldOverlapWhenKeyboardWillShow: input.keyboardWillShowNotificationReceived
                .asDriverOnErrorJustComplete(),
            resetActiveTextFieldPositionWhenKeyboardWillHide: input.keyboardWillHideNotificationReceived
                .asDriverOnErrorJustComplete()
        )
    }
}
