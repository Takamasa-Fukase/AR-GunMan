//
//  RegisterNameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import RxSwift
import RxCocoa

protocol NameRegisterDelegate: AnyObject {
    func onClose(registeredRanking: Ranking?)
}

class NameRegisterViewModel {
    let rankText: Observable<String>
    let totalScore: Observable<Double>
    let isRegisterButtonEnabled: Observable<Bool>
    let dismiss: Observable<Void>
    let isRegistering: Observable<Bool>
    let error: Observable<Error>
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nameTextFieldChanged: Observable<String>
        let registerButtonTapped: Observable<Void>
        let noButtonTapped: Observable<Void>
    }
    
    struct Dependency {
        let rankingRepository: RankingRepository
        let totalScore: Double
        let rankingListObservable: Observable<[Ranking]>
        weak var delegate: NameRegisterDelegate?
    }
    
    init(input: Input, dependency: Dependency) {
        let rankTextRelay = BehaviorRelay<String>(value: "  /  ")
        self.rankText = rankTextRelay.asObservable()
        
        self.totalScore = Observable.just(dependency.totalScore)
        
        self.isRegisterButtonEnabled = input.nameTextFieldChanged
            .map({ element in
                return !element.isEmpty
            })
        
        let dismissRelay = PublishRelay<Void>()
        self.dismiss = dismissRelay.asObservable()
        
        let isRegisteringRelay = BehaviorRelay<Bool>(value: false)
        self.isRegistering = isRegisteringRelay.asObservable()
        
        let errorRelay = PublishRelay<Error>()
        self.error = errorRelay.asObservable()
        
        input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .subscribe(onNext: { element in
                Task { @MainActor in
                    isRegisteringRelay.accept(true)
                    do {
                        let ranking = Ranking(score: dependency.totalScore, userName: element)
                        try await dependency.rankingRepository.registerRanking(ranking)
                        dependency.delegate?.onClose(registeredRanking: ranking)
                        dismissRelay.accept(Void())
                    } catch {
                        errorRelay.accept(error)
                    }
                    isRegisteringRelay.accept(false)
                }
            }).disposed(by: disposeBag)
        
        input.noButtonTapped
            .subscribe(onNext: { _ in
                dependency.delegate?.onClose(registeredRanking: nil)
                dismissRelay.accept(Void())
            }).disposed(by: disposeBag)
        
        dependency.rankingListObservable
            .filter({ !$0.isEmpty })
            .map({ rankingList in
                return RankingUtil.createTemporaryRankText(
                    rankingList: rankingList,
                    score: dependency.totalScore
                )
            })
            .bind(to: rankTextRelay)
            .disposed(by: disposeBag)
    }
}
