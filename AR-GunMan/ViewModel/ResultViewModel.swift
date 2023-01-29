//
//  ResultViewModel.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 28/1/23.
//

import RxSwift
import RxCocoa

class ResultViewModel {
    let rankingList: Observable<[Ranking]?>
    let showNameRegisterView: Observable<Void>
    var showButtons: Observable<Void> {
        return showButtonsRelay.asObservable()
    }
    let backToTopPageViewWithReplay: Observable<Bool>
    
    private let showButtonsRelay = PublishRelay<Void>()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let replayButtonTapped: Observable<Void>
        let toHomeButtonTapped: Observable<Void>
    }
    
    init(input: Input) {
        let rankingListRelay = PublishRelay<[Ranking]?>()
        self.rankingList = rankingListRelay.asObservable()
        
        let showNameRegisterViewRelay = PublishRelay<Void>()
        self.showNameRegisterView = showNameRegisterViewRelay.asObservable()
        
        input.viewWillAppear
            .subscribe(onNext: { _ in
                Task { @MainActor in
                    await rankingListRelay.accept(RankingRepository.getRanking())
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showNameRegisterViewRelay.accept(Void())
                }
            }).disposed(by: disposeBag)

        let backToTopPageViewWithReplayRelay = PublishRelay<Bool>()
        self.backToTopPageViewWithReplay = backToTopPageViewWithReplayRelay.asObservable()
        
        input.replayButtonTapped
            .map({_ in true})
            .bind(to: backToTopPageViewWithReplayRelay)
            .disposed(by: disposeBag)
        
        input.toHomeButtonTapped
            .map({_ in false})
            .bind(to: backToTopPageViewWithReplayRelay)
            .disposed(by: disposeBag)
    }
}

extension ResultViewModel: NameRegisterDelegate {
    func viewDidDisappear() {
        showButtonsRelay.accept(Void())
    }
}



