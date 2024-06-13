//
//  NameRegisterViewModel2.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 12/6/24.
//

import RxSwift
import RxCocoa

final class NameRegisterEventReceiver2 {
    let onRegisterComplete = PublishRelay<Ranking>()
    let onClose = PublishRelay<Void>()
}

final class NameRegisterViewModel2: ViewModelType {
    struct Input {
        let viewWillDisappear: Observable<Void>
        let nameTextFieldChanged: Observable<String>
        let registerButtonTapped: Observable<Void>
        let noButtonTapped: Observable<Void>
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
                
        struct ViewModelAction {
            let rankingRegistered: Observable<Ranking>
            let registerCompleteEventSent: Observable<Ranking>
            let closeEventSent: Observable<Void>
            let viewDismissed: Observable<Void>
            let errorAlertShowed: Observable<Error>
        }
        
        struct OutputToView {
            let temporaryRankText: Observable<String>
            let scoreText: Observable<String>
            let isRegisterButtonEnabled: Observable<Bool>
            let isRegistering: Observable<Bool>
        }
    }
    
    struct State {}
    
    private let useCase: NameRegisterUseCaseInterface
    private let navigator: NameRegisterNavigatorInterface2
    private let score: Double
    private let temporaryRankTextObservable: Observable<String>
    private weak var eventReceiver: NameRegisterEventReceiver2?
        
    init(
        useCase: NameRegisterUseCaseInterface,
        navigator: NameRegisterNavigatorInterface2,
        score: Double,
        temporaryRankTextObservable: Observable<String>,
        eventReceiver: NameRegisterEventReceiver2?
    ) {
        self.useCase = useCase
        self.navigator = navigator
        self.score = score
        self.temporaryRankTextObservable = temporaryRankTextObservable
        self.eventReceiver = eventReceiver
    }
    
    func transform(input: Input) -> Output {
        let registerActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        
        // MARK: - ViewModelAction
        let closeEventSent = input.viewWillDisappear
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.eventReceiver?.onClose.accept(())
            })
        
        let rankingRegistered = input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .flatMapLatest({ [weak self] userName -> Observable<Ranking> in
                guard let self = self else { return .empty() }
                let ranking = Ranking(score: self.score, userName: userName)
                return self.useCase.registerRanking(ranking)
                    .trackActivity(registerActivityTracker)
                    .trackError(errorTracker)
            })
            .share()
        
        let registerCompleteEventSent = rankingRegistered
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.eventReceiver?.onRegisterComplete.accept($0)
            })
        
        let viewDismissed = rankingRegistered
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            })
            .map({ _ in })
        
        let errorAlertShowed = errorTracker.asObservable()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigator.showErrorAlert($0)
            })
        
        
        // MARK: - OutputToView
        let temporaryRankText = temporaryRankTextObservable
        
        let scoreText = Observable.just("Score: \(score.scoreText)")
        
        let isRegisterButtonEnabled = input.nameTextFieldChanged
            .map({ !$0.isEmpty })
        
        let isRegistering = registerActivityTracker.asObservable()
        
        
        return Output(
            viewModelAction: Output.ViewModelAction(
                rankingRegistered: rankingRegistered,
                registerCompleteEventSent: registerCompleteEventSent,
                closeEventSent: closeEventSent,
                viewDismissed: viewDismissed,
                errorAlertShowed: errorAlertShowed
            ),
            outputToView: Output.OutputToView(
                temporaryRankText: temporaryRankText,
                scoreText: scoreText,
                isRegisterButtonEnabled: isRegisterButtonEnabled,
                isRegistering: isRegistering
            )
        )
    }
}
