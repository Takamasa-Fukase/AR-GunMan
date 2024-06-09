//
//  GameUseCase.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/14.
//

import RxSwift
import SceneKit

protocol GameUseCaseInterface {
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen() -> Observable<Void>
    func awaitTimerStartSignal() -> Observable<Void>
    func awaitShowResultSignal() -> Observable<Void>
    func awaitWeaponReloadEnds(currentWeapon: WeaponType) -> Observable<WeaponType>
    func getTimeCountStream() -> Observable<Double>
}

final class GameUseCase: GameUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface
    private let timerRepository: TimerRepositoryInterface
    
    init(
        tutorialRepository: TutorialRepositoryInterface,
        timerRepository: TimerRepositoryInterface
    ) {
        self.tutorialRepository = tutorialRepository
        self.timerRepository = timerRepository
    }
    
    func getIsTutorialSeen() -> Observable<Bool> {
        return tutorialRepository.getIsTutorialSeen()
    }
    
    func setTutorialAlreadySeen() -> Observable<Void> {
        return tutorialRepository.setTutorialAlreadySeen()
    }
    
    func awaitTimerStartSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.timerStartWaitingTimeMillisec,
                isRepeated: false
            )
            .map({ _ in })
    }

    func awaitShowResultSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.showResultWaitingTimeMillisec,
                isRepeated: false
            )
            .map({ _ in })
    }
    
    func awaitWeaponReloadEnds(currentWeapon: WeaponType) -> Observable<WeaponType> {
        return timerRepository
            .getTimerStream(
                milliSec: currentWeapon.reloadWaitingTimeMillisec,
                isRepeated: false
            )
            .map({ _ in currentWeapon })
    }
    
    func getTimeCountStream() -> Observable<Double> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.timeCountUpdateDurationMillisec,
                isRepeated: true
            )
            .map({ timerUpdatedCount in // タイマーが更新された回数を表すInt
                // 例: 30.00 - (1 / 100) => 29.99
                return GameConst.timeCount - (Double(timerUpdatedCount) / 100)
            })
    }
}

