//
//  GameScenarioHandlingUseCase.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 3/7/24.
//

import RxSwift
import RxCocoa

struct GameScenarioHandlingInput {
    let tutorialSeenCheckTrigger: Observable<Void>
    let tutorialEnded: Observable<Void>
}

struct GameScenarioHandlingOutput {
    let showTutorial: Observable<Void>
    let startDeviceMotionDetection: Observable<Void>
    let updateTimeCount: Observable<Double>
    let stopDeviceMotionDetection: Observable<Void>
    let dismissWeaponChangeView: Observable<Void>
    let showResultView: Observable<Void>
}

protocol GameScenarioHandlingUseCaseInterface {
    func generateOutput(from input: GameScenarioHandlingInput) -> GameScenarioHandlingOutput
}

final class GameScenarioHandlingUseCase: GameScenarioHandlingUseCaseInterface {
    private let tutorialRepository: TutorialRepositoryInterface
    private let timerStreamCreator: TimerStreamCreator
    private let soundPlayer: SoundPlayerInterface
    private let disposeBag = DisposeBag()
    
    init(
        tutorialRepository: TutorialRepositoryInterface,
        timerStreamCreator: TimerStreamCreator = TimerStreamCreator(),
        soundPlayer: SoundPlayerInterface = SoundPlayer.shared
    ) {
        self.tutorialRepository = tutorialRepository
        self.timerStreamCreator = timerStreamCreator
        self.soundPlayer = soundPlayer
    }
    
    func generateOutput(from input: GameScenarioHandlingInput) -> GameScenarioHandlingOutput {
        let updateTimeCountRelay = PublishRelay<Double>()
        let timerEndedRelay = PublishRelay<Void>()
        
        // チュートリアルを既に見たかどうかチェック
        let isTutorialAlreadySeen = input.tutorialSeenCheckTrigger
            .flatMapLatest({  [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.tutorialRepository.getIsTutorialSeen()
            })
        // - まだ見ていない ⇒ チュートリアルを表示
        let tutorialShowingTrigger = isTutorialAlreadySeen
            .filter({ !$0 })
            .mapToVoid()
        // - 既に見た ⇒ ゲーム開始指示
        let gameStartTrigger = isTutorialAlreadySeen
            .filter({ $0 })
            .mapToVoid()
        
        // チュートリアル終了通知の受信契機でチュートリアル完了フラグを保存
        let tutorialSeenFlagSetCompleted = input.tutorialEnded
            .flatMapLatest({  [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.tutorialRepository.setTutorialAlreadySeen()
            })
            
        // ゲーム開始トリガーを合成
        let combinedGameStartTrigger = Observable
            .merge(
                gameStartTrigger,
                tutorialSeenFlagSetCompleted
            )
        
        // タイマー開始の待ち時間を開始
        let timerStartTrigger = combinedGameStartTrigger
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.timerStreamCreator
                    .create(
                        milliSec: GameConst.timerStartWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .mapToVoid()
            })
            .share()
        
        // 0.01秒ごとのタイマー受信を開始
        let periodicTimerStream = timerStartTrigger
            .flatMapLatest({ [weak self] _ -> Observable<Double> in
                guard let self = self else { return .empty() }
                return self.timerStreamCreator
                    .create(
                        milliSec: GameConst.timeCountUpdateDurationMillisec,
                        isRepeated: true
                    )
                    .map({ timerUpdatedCount in // タイマーが更新された回数を表すInt
                        // 例: 30.00 - (1 / 100) => 29.99
                        return GameConst.timeCount - (Double(timerUpdatedCount) / 100)
                    })
            })
            .take(while: { $0 >= 0 }) // 条件がfalseになるとcompletedが呼ばれる
        
        // 結果画面表示の待ち時間を開始
        let resultViewShowingTrigger = timerEndedRelay
            .flatMapLatest({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                return self.timerStreamCreator
                    .create(
                        milliSec: GameConst.showResultWaitingTimeMillisec,
                        isRepeated: false
                    )
                    .mapToVoid()
            })
            .share()
        
        disposeBag.insert {
            gameStartTrigger
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    // 🟨 音声の再生<銃を構える音>
                    self.soundPlayer.play(.pistolSet)
                })
            timerStartTrigger
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    // 🟨 音声の再生<開始の笛>
                    self.soundPlayer.play(.startWhistle)
                })
            periodicTimerStream
                .subscribe(
                    onNext: {
                        // 🟥 Stateの更新指示<タイマー受信ごとのタイムカウントを通知>
                        updateTimeCountRelay.accept($0)
                    },
                    onCompleted: { [weak self] in
                        guard let self = self else { return }
                        // 🟨 音声の再生<終了の笛>
                        self.soundPlayer.play(.endWhistle)
                        
                        // タイマー終了通知
                        timerEndedRelay.accept(())
                    }
                )
            resultViewShowingTrigger
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else {return}
                    // 🟨 音声の再生<結果画面表示の音声>
                    self.soundPlayer.play(.rankingAppear)
                })
        }
        
        return GameScenarioHandlingOutput(
            showTutorial: tutorialShowingTrigger,
            startDeviceMotionDetection: timerStartTrigger,
            updateTimeCount: updateTimeCountRelay.asObservable(),
            stopDeviceMotionDetection: timerEndedRelay.asObservable(),
            dismissWeaponChangeView: timerEndedRelay.asObservable(),
            showResultView: resultViewShowingTrigger
        )
    }
}
