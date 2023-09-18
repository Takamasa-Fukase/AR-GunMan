//
//  RegisterNameViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/01/25.
//

import RxSwift
import RxCocoa

protocol NameRegisterDelegate: AnyObject {
    func showRightButtons()
}

class NameRegisterViewModel {
    let rankingDisplayText: Observable<NSAttributedString>
    let totalScoreText: Observable<String>
    let isRegisterButtonEnabled: Observable<Bool>
    let dismiss: Observable<Void>
    let isLoading: Observable<Bool>
    let error: Observable<Error>
    
    private let disposeBag = DisposeBag()
    
    struct Input {
        let nameTextFieldChanged: Observable<String>
        let registerButtonTapped: Observable<Void>
        let noButtonTapped: Observable<Void>
        let viewDidDisappear: Observable<Void>
    }
    
    struct Dependency {
        let totalScore: Double
        let tentativeRank: Int
        let rankingLength: Int
        let threeDigitsScore: Double
        weak var delegate: NameRegisterDelegate?
        let rankingRepository: RankingRepository
    }
    
    init(input: Input, dependency: Dependency) {
        self.rankingDisplayText = Observable.just(createRankingDisplayText())
        
        self.totalScoreText = Observable.just(createTotalScoreText())
        
        self.isRegisterButtonEnabled = input.nameTextFieldChanged
            .map({ element in
                return !element.isEmpty
            })
        
        let dismissRelay = PublishRelay<Void>()
        self.dismiss = dismissRelay.asObservable()
        
        let isLoadingRelay = BehaviorRelay<Bool>(value: false)
        self.isLoading = isLoadingRelay.asObservable()
        
        let errorRelay = PublishRelay<Error>()
        self.error = errorRelay.asObservable()
        
        input.registerButtonTapped
            .withLatestFrom(input.nameTextFieldChanged)
            .subscribe(onNext: { element in
                isLoadingRelay.accept(true)
                do {
                    let ranking = Ranking(score: dependency.threeDigitsScore, userName: element)
                    try dependency.rankingRepository.registerRanking(ranking)
                    dismissRelay.accept(Void())
                }catch {
                    errorRelay.accept(error)
                }
                isLoadingRelay.accept(false)
            }).disposed(by: disposeBag)
        
        input.noButtonTapped
            .bind(to: dismissRelay)
            .disposed(by: disposeBag)
        
        input.viewDidDisappear
            .subscribe(onNext: { _ in
                dependency.delegate?.showRightButtons()
            }).disposed(by: disposeBag)
        
        func createRankingDisplayText() -> NSMutableAttributedString {
            let mutableAttributedString = NSMutableAttributedString()
            [UIFont.attributedString("You're ranked at ",
                                     fontName: "Copperplate",
                                     fontSize: 21,
                                     textColor: .init(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)),
             UIFont.attributedString("\(dependency.tentativeRank) / \(dependency.rankingLength)",
                                     fontName: "Copperplate",
                                     fontSize: 25,
                                     textColor: .init(red: 85/255, green: 78/255, blue: 72/255, alpha: 1)),
             UIFont.attributedString(" in the world!",
                                     fontName: "Copperplate",
                                     fontSize: 21,
                                     textColor: .init(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)),
            ].forEach({ element in
                mutableAttributedString.append(element)
            })
            return mutableAttributedString
        }
        
        func createTotalScoreText() -> String {
            return "Score: \(String(format: "%.3f", dependency.totalScore))"
        }
    }
}
