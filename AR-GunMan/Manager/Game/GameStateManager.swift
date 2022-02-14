////
////  GameStateManager.swift
////  AR-GunMan
////
////  Created by ウルトラ深瀬 on 2022/02/02.
////

import Foundation
import RxSwift
import RxCocoa

enum GameStatus {
    case ready
    case start
    case switchWeapon
    case pause
    case finish
}

enum WeaponFirableReaction {
    case fireAvailable
    case fireUnavailable
    case noBullets
}

class GameStateManager {
    //MARK: - input
    let startGame: AnyObserver<Void>
    let requestFiringWeapon: AnyObserver<Void>
    let requestReloadingWeapon: AnyObserver<Void>
    let requestShowingSwitchWeaponPage: AnyObserver<Void>
    let requestSwitchingWeapon: AnyObserver<WeaponTypes>
    let hitTarget: AnyObserver<Void>

    //MARK: - output
    let gameStatusChanged: Observable<GameStatus>
    let timeCount: Observable<Double>
    let weaponSelected: Observable<WeaponTypes>
    let weaponFirableReaction: Observable<WeaponFirableReaction>
    let isReloadWeaponEnabled: Observable<Bool>
    let totalScore: Observable<Double>

    //count
//    let explosionCount: Observable<Int>

    //nodeAnimation
//    let toggleActionInterval = 0.2
//    let lastCameraPos: (Float, Float, Float) = (0, 0, 0)
//    let isPlayerRunning = false
//    let lastPlayerStatus = false

    //other
    private let disposeBag = DisposeBag()

    init() {
        //other
        let _pistolBulletsCount = BehaviorRelay<Int>(value: Const.pistolBulletsCapacity)
        let _bazookaBulletsCount = BehaviorRelay<Int>(value: Const.bazookaBulletsCapacity)

        //MARK: - output
        let _gameStatusChanged = BehaviorRelay<GameStatus>(value: .ready)
        self.gameStatusChanged = _gameStatusChanged.asObservable()

        let _timeCount = BehaviorRelay<Double>(value: Const.timeCount)
        self.timeCount = _timeCount.asObservable()

        let _weaponSelected = BehaviorRelay<WeaponTypes>(value: .pistol)
        self.weaponSelected = _weaponSelected.asObservable()

        let _weaponFirableReaction = BehaviorRelay<WeaponFirableReaction>(value: .fireUnavailable)
        self.weaponFirableReaction = _weaponFirableReaction.asObservable()

        let _isReloadWeaponEnabled = BehaviorRelay<Bool>(value: false)
        self.isReloadWeaponEnabled = _isReloadWeaponEnabled.asObservable()
        
        let _totalScore = BehaviorRelay<Double>(value: 0.0)
        self.totalScore = _totalScore.asObservable()
        
        
        //other (output変数を参照するためここに配置)
        let _ = TimeCountUtil.createRxTimer(.nanoseconds(1))
            .filter({ _ in _gameStatusChanged.value == .start ||
                    _gameStatusChanged.value == .pause })
            .map({ TimeCountUtil.decreaseGameTimeCount(elapsedTime: Double($0 / 100)) })
            .subscribe(onNext: { element in
                _timeCount.accept(element)
                if element <= 0 {
                    _gameStatusChanged.accept(.finish)
                }
            }).disposed(by: disposeBag)
        

        //MARK: - input
        self.startGame = AnyObserver<Void>() { _ in
            _gameStatusChanged.accept(.start)
        }

        self.requestFiringWeapon = AnyObserver<Void>() { _ in
            //現在の武器が発射可能な条件かどうかチェックし、リアクションを返す
            _weaponFirableReaction.accept(
                WeaponStatusUtil
                    .checkFireAvailable(
                        gameStatus: _gameStatusChanged.value,
                        currentWeapon: _weaponSelected.value,
                        pistolBulletsCount: _pistolBulletsCount.value,
                        bazookaBulletsCount: _bazookaBulletsCount.value
                    )
            )
        }

        self.requestReloadingWeapon = AnyObserver<Void>() { _ in
            //現在の武器がリロード可能な条件かどうかチェックし、リアクションを返す
            _isReloadWeaponEnabled.accept(
                WeaponStatusUtil
                    .checkReloadAvailable(
                        gameStatus: _gameStatusChanged.value,
                        currentWeapon: _weaponSelected.value,
                        pistolBulletsCount: _pistolBulletsCount.value
                    )
            )
        }
        
        self.requestShowingSwitchWeaponPage = AnyObserver<Void>() { _ in
            _gameStatusChanged.accept(.switchWeapon)
        }
        
        self.requestSwitchingWeapon = AnyObserver<WeaponTypes>() { event in
            guard let element = event.element else {return}
            //同じ武器が選択されても武器選択画面を閉じる処理が必要なのでそのまま流す
            _weaponSelected.accept(element)
        }
        
        self.hitTarget = AnyObserver<Void>() { _ in
            _totalScore.accept(ScoreUtil.addScore(currentScore: _totalScore.value, weapon: _weaponSelected.value))
        }
    }

}
