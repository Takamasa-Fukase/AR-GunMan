//
//  ResultUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/04/18.
//

import RxSwift

protocol ResultUseCaseInterface {
    func getRanking() -> Single<[Ranking]>
    func awaitShowNameRegisterSignal() -> Observable<Void>
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void>
}

final class ResultUseCase: ResultUseCaseInterface {
    private let rankingRepository: RankingRepositoryInterface
    private let timerRepository: TimerRepositoryInterface
    private let replayRepository: ReplayRepositoryInterface
    
    init(
        rankingRepository: RankingRepositoryInterface,
        timerRepository: TimerRepositoryInterface,
        replayRepository: ReplayRepositoryInterface
    ) {
        self.rankingRepository = rankingRepository
        self.timerRepository = timerRepository
        self.replayRepository = replayRepository
    }
    
    func getRanking() -> Single<[Ranking]> {
        return rankingRepository.getRanking()
    }
    
    func awaitShowNameRegisterSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: ResultConst.showNameRegisterWaitingTimeMillisec,
                isRepeated: false
            )
            .mapToVoid()
    }
    
    func setNeedsReplay(_ newValue: Bool) -> Observable<Void> {
        return replayRepository.setNeedsReplay(newValue)
    }
}
