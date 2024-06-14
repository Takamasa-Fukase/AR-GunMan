//
//  RankingViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import RxSwift
import RxCocoa

final class RankingViewModel: ViewModelType {
    struct Input {
        let viewWillAppear: Observable<Void>
        let closeButtonTapped: Observable<Void>
    }
    
    struct Output {
        let viewModelAction: ViewModelAction
        let outputToView: OutputToView
                
        struct ViewModelAction {
            let viewDismissed: Observable<Void>
            let errorAlertShowed: Observable<Error>
        }
        
        struct OutputToView {
            let rankingList: Observable<[Ranking]>
            let isLoadingRankingList: Observable<Bool>
        }
    }
    
    struct State {}
    
    private let useCase: RankingUseCaseInterface
    private let navigator: RankingNavigatorInterface
    
    init(
        useCase: RankingUseCaseInterface,
        navigator: RankingNavigatorInterface
    ) {
        self.useCase = useCase
        self.navigator = navigator
    }

    func transform(input: Input) -> Output {
        let rankingLoadActivityTracker = ObservableActivityTracker()
        let errorTracker = ObservableErrorTracker()
        
        // MARK: - ViewModelAction
        let viewDismissed = input.closeButtonTapped
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.dismiss()
            })
        
        let errorAlertShowed = errorTracker.asObservable()
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigator.showErrorAlert($0)
            })
        
        
        // MARK: - OutputToView
        let rankingList = input.viewWillAppear
            .take(1)
            .flatMapLatest({ [weak self] _ -> Observable<[Ranking]> in
                guard let self = self else { return .empty() }
                return self.useCase.getRanking()
                    .trackActivity(rankingLoadActivityTracker)
                    .trackError(errorTracker)
                    .catchErrorJustComplete()
            })
        
        let isLoadingRankingList = rankingLoadActivityTracker.asObservable()
        
        
        return Output(
            viewModelAction: Output.ViewModelAction(
                viewDismissed: viewDismissed,
                errorAlertShowed: errorAlertShowed),
            outputToView: Output.OutputToView(
                rankingList: rankingList,
                isLoadingRankingList: isLoadingRankingList
            )
        )
    }
}


