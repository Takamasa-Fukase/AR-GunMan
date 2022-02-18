////
////  GameStateManager.swift
////  AR-GunMan
////
////  Created by ウルトラ深瀬 on 2022/02/02.
////

import Foundation
import RxSwift
import RxCocoa

class GameStateManager {
    //MARK: - input
    let startGame: AnyObserver<Void>
    let requestFiringWeapon: AnyObserver<Void>
    let requestReloadingWeapon: AnyObserver<Void>
    let requestSwitchingWeapon: AnyObserver<WeaponTypes>
    let addScore: AnyObserver<Void>

    //MARK: - output
    let gameStatusChanged: Observable<GameStatus>
    let timeCount: Observable<Double>
    let weaponSwitchingResult: Observable<WeaponSwitchingResult>
    let weaponFiringResult: Observable<WeaponFiringResult>
    let weaponReloadingResult: Observable<WeaponReloadingResult>
    let totalScore: Observable<Double>

    //other
    private let disposeBag = DisposeBag()

    init() {
        //other
        let _pistolBulletsCount = BehaviorRelay<Int>(value: Const.pistolBulletsCapacity)
        let _bazookaBulletsCount = BehaviorRelay<Int>(value: Const.bazookaBulletsCapacity)
        
        func createFiringResult(excuteBazookaAutoReloading: (() -> Void)) -> WeaponFiringResult {
            //現在の武器が発射可能な条件かどうかチェックし、結果を返す
            return WeaponStatusUtil
                .createWeaponFiringResult(
                    gameStatus: _gameStatusChanged.value,
                    currentWeapon: _weaponSwitchingResult.value.weapon,
                    pistolBulletsCount: _pistolBulletsCount,
                    bazookaBulletsCount: _bazookaBulletsCount,
                    excuteBazookaAutoReloading: excuteBazookaAutoReloading
                )
        }
        
        func createReloadingResult() -> WeaponReloadingResult {
            //現在の武器がリロード可能な条件かどうかチェックし、結果を返す
            return WeaponStatusUtil
                .createWeaponReloadingResult(
                    gameStatus: _gameStatusChanged.value,
                    currentWeapon: _weaponSwitchingResult.value.weapon,
                    pistolBulletsCount: _pistolBulletsCount,
                    bazookaBulletsCount: _bazookaBulletsCount
                )
        }
        
        func createSwitchingResult(selectedWeapon: WeaponTypes) -> WeaponSwitchingResult {
            //現在の武器がリロード可能な条件かどうかチェックし、結果を返す
            return WeaponStatusUtil
                .createWeaponSwitchingResult(
                    currentWeapon: _weaponSwitchingResult.value.weapon,
                    selectedWeapon: selectedWeapon,
                    pistolBulletsCount: _pistolBulletsCount,
                    bazookaBulletsCount: _bazookaBulletsCount
                )
        }
        

        //MARK: - output
        let _gameStatusChanged = BehaviorRelay<GameStatus>(value: .pause)
        self.gameStatusChanged = _gameStatusChanged.asObservable()

        let _timeCount = BehaviorRelay<Double>(value: Const.timeCount)
        self.timeCount = _timeCount.asObservable()

        let _weaponSwitchingResult = BehaviorRelay<WeaponSwitchingResult>(value: WeaponSwitchingResult(switched: true, weapon: .pistol, bulletsCount: Const.pistolBulletsCapacity))
        self.weaponSwitchingResult = _weaponSwitchingResult.asObservable()

        let _weaponFiringResult = PublishRelay<WeaponFiringResult>()
        self.weaponFiringResult = _weaponFiringResult.asObservable()

        let _weaponReloadingResult = PublishRelay<WeaponReloadingResult>()
        self.weaponReloadingResult = _weaponReloadingResult.asObservable()
        
        let _totalScore = BehaviorRelay<Double>(value: 0.0)
        self.totalScore = _totalScore.asObservable()
        
        
        //other (output変数を参照するためここに配置)
        let _ = TimeCountUtil.createRxTimer(.milliseconds(10))
            .filter({ _ in _gameStatusChanged.value == .playing })
            .subscribe(onNext: { element in
                _timeCount.accept(
                    TimeCountUtil.decreaseGameTimeCount(lastValue: _timeCount.value)
                )
                if element <= 0 {
                    _gameStatusChanged.accept(.finish)
                }
            }).disposed(by: disposeBag)
        

        //MARK: - input
        self.startGame = AnyObserver<Void>() { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                AudioUtil.playSound(of: .startWhistle)
                _gameStatusChanged.accept(.playing)
            }
        }

        self.requestFiringWeapon = AnyObserver<Void>() { _ in
            let firingResult = createFiringResult(
                excuteBazookaAutoReloading: {
                    //バズーカは自動リロード（3.2秒後に完了）
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                        //バズーカ残弾数をMAXに補充
                        _bazookaBulletsCount.accept(Const.bazookaBulletsCapacity)
                        //残弾数がある状態でリロード結果を作成して流す
                        _weaponReloadingResult.accept(createReloadingResult())
                    }
                })
            
            _weaponFiringResult.accept(firingResult)
        }

        self.requestReloadingWeapon = AnyObserver<Void>() { _ in
            _weaponReloadingResult.accept(createReloadingResult())
        }
        
        self.requestSwitchingWeapon = AnyObserver<WeaponTypes>() { event in
            guard let element = event.element else {return}
            
            _weaponSwitchingResult.accept(
                createSwitchingResult(selectedWeapon: element)
            )
        }
        
        self.addScore = AnyObserver<Void>() { _ in
            _totalScore.accept(
                ScoreUtil.addScore(currentScore: _totalScore.value,
                                   weapon: _weaponSwitchingResult.value.weapon)
            )
            switch _weaponSwitchingResult.value.weapon {
            case .pistol:
                AudioUtil.playSound(of: .headShot)
            case .bazooka:
                AudioUtil.playSound(of: .bazookaHit)
            default:
                 break
            }
        }
    }

}
