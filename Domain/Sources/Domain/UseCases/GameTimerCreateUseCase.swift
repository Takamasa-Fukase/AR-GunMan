//
//  GameTimerCreateUseCase.swift
//  Sample_AR-GunMan_Replace
//
//  Created by ウルトラ深瀬 on 11/11/24.
//

import Foundation

public struct GameTimerCreateRequest {
    public final class PauseController {
        public var isPaused = false
        
        public init(isPaused: Bool = false) {
            self.isPaused = isPaused
        }
    }
    let initialTimeCount: Double
    let updateInterval: TimeInterval
    let pauseController: PauseController
    
    public init(
        initialTimeCount: Double,
        updateInterval: TimeInterval,
        pauseController: PauseController
    ) {
        self.initialTimeCount = initialTimeCount
        self.updateInterval = updateInterval
        self.pauseController = pauseController
    }
}

public struct TimerStartedResponse {
    public let startWhistleSound: SoundType
}

public struct TimerUpdatedResponse {
    public let timeCount: Double
}

public struct TimerEndedResponse {
    public let endWhistleSound: SoundType
    public let rankingAppearSound: SoundType
}

public protocol GameTimerCreateUseCaseInterface {
    func execute(
        request: GameTimerCreateRequest,
        onTimerStarted: @escaping ((TimerStartedResponse) -> Void),
        onTimerUpdated: @escaping ((TimerUpdatedResponse) -> Void),
        onTimerEnded: @escaping ((TimerEndedResponse) -> Void)
    )
}

public final class GameTimerCreateUseCase: GameTimerCreateUseCaseInterface {
    public init() {}
    
    public func execute(
        request: GameTimerCreateRequest,
        onTimerStarted: @escaping ((TimerStartedResponse) -> Void),
        onTimerUpdated: @escaping ((TimerUpdatedResponse) -> Void),
        onTimerEnded: @escaping ((TimerEndedResponse) -> Void)
    ) {
        // UseCase内での計算にはInt型のミリ秒に変換したものを使う（誤差の無い正確な計算を行う為）
        let initialTimeCountMillisec = Int(request.initialTimeCount * 1000)
        let updateIntervalMillisec = Int(request.updateInterval * 1000)
        
        // このミリ秒の変数を減算していく
        var timeCountMillisec: Int = initialTimeCountMillisec
        
        _ = Timer.scheduledTimer(
            // 引数に合わせてTimeInterval型のまま渡す
            withTimeInterval: request.updateInterval,
            repeats: true
        ) { timer in
            
            // 初回のタイマー呼び出しの判定
            if (timeCountMillisec == initialTimeCountMillisec) {
                
                // タイマーが開始されたことをコールバックで通知
                onTimerStarted(TimerStartedResponse(startWhistleSound: .startWhistle))
            }
            
            // ポーズ中ではない場合
            if !request.pauseController.isPaused {
                
                // ここで減算
                timeCountMillisec -= updateIntervalMillisec
                
                // View側では「30.00」の様に少数表示をしている為、Double型に戻してから渡す
                let timeCountDouble = Double(timeCountMillisec) / Double(1000)
                
                // タイマーが更新されたことをコールバックで通知
                onTimerUpdated(TimerUpdatedResponse(timeCount: timeCountDouble))
            }
            
            // タイマーが0の場合
            if timeCountMillisec <= 0 {
                
                // タイマーが終了したことをコールバックで通知
                onTimerEnded(TimerEndedResponse(
                    endWhistleSound: .endWhistle,
                    rankingAppearSound: .rankingAppear
                ))
                
                // タイマーを破棄する
                timer.invalidate()
            }
        }
    }
}
