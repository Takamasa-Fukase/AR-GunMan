//
//  GameUseCase2.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/14.
//

import RxSwift
import SceneKit

protocol GameUseCase2Interface {
    func getIsTutorialSeen() -> Observable<Bool>
    func setTutorialAlreadySeen() -> Observable<Void>
    func awaitGameStartSignal() -> Observable<Void>
    func awaitShowResultSignal() -> Observable<Void>
    func awaitWeaponReloadEnds(currentWeapon: WeaponType) -> Observable<Void>
    func getTimeCountStream() -> Observable<Double>
}

final class GameUseCase2: GameUseCase2Interface {
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
    
    func awaitGameStartSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.gameStartWaitingTimeMillisec,
                isRepeatd: false
            )
            .map({ _ in })
    }

    func awaitShowResultSignal() -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.showResultWaitingTimeMillisec,
                isRepeatd: false
            )
            .map({ _ in })
    }
    
    func awaitWeaponReloadEnds(currentWeapon: WeaponType) -> Observable<Void> {
        return timerRepository
            .getTimerStream(
                milliSec: currentWeapon.reloadDurationMillisec,
                isRepeatd: false
            )
            .map({ _ in })
    }
    
    func getTimeCountStream() -> Observable<Double> {
        return timerRepository
            .getTimerStream(
                milliSec: GameConst.timeCountUpdateDurationMillisec,
                isRepeatd: true
            )
            .map({ timerUpdatedCount in // タイマーが更新された回数を表すInt
                // 例: 30.00 - (1 / 100) => 29.99
                return max(GameConst.timeCount - (Double(timerUpdatedCount) / 100), 0)
            })
    }
}

