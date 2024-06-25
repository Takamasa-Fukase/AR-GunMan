//
//  ResultPresenter.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 25/6/24.
//

//import RxSwift
//import RxCocoa
//
//struct ResultControllerInput {
//    let viewWillAppear: Observable<Void>
//    let replayButtonTapped: Observable<Void>
//    let toHomeButtonTapped: Observable<Void>
//}
//
//struct ResultViewModel {
//    let rankingList: Observable<[Ranking]>
//    let scoreText: Observable<String>
//    let showButtons: Observable<Void>
//    let scrollCellToCenter: Observable<IndexPath>
//    let isLoadingRankingList: Observable<Bool>
//}
//
//protocol ResultPresenterInterface {
//    func transform(input: ResultControllerInput) -> ResultViewModel
//}
//
//final class ResultPresenter: ResultPresenterInterface {
//    private let navigator: ResultNavigatorInterface
//    private let score: Double
//    
//    // 遷移先からの通知を受け取るレシーバー
//    private let nameRegisterEventReceiver: NameRegisterEventReceiver
//    
//    private let disposeBag = DisposeBag()
//    
//    init(
//        navigator: ResultNavigatorInterface,
//        score: Double,
//        nameRegisterEventReceiver: NameRegisterEventReceiver = NameRegisterEventReceiver()
//    ) {
//        self.navigator = navigator
//        self.score = score
//        self.nameRegisterEventReceiver = nameRegisterEventReceiver
//    }
//    
//    func transform(input: ResultControllerInput) -> ResultViewModel {
//        let rankingLoadActivityTracker = ObservableActivityTracker()
//        let errorTracker = ObservableErrorTracker()
//        
//        disposeBag.insert {
//            
//        }
//        
//        return ResultViewModel(
//            rankingList: ,
//            scoreText: ,
//            showButtons: ,
//            scrollCellToCenter: ,
//            isLoadingRankingList:
//        )
//    }
//}
