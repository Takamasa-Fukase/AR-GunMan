//
//  GameConst.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/19.
//

final class GameConst {
    // ゲームの的の数
    static let targetCount: Int = 50
    // ゲームのタイムカウント
    static let timeCount: Double = 30.00
    // タイマー開始までの待ち時間
    static let timerStartWaitingTimeMillisec: Int = 1500
    // タイマー終了後に結果画面へ遷移するまでの待ち時間
    static let showResultWaitingTimeMillisec: Int = 1500
    // ゲームのタイムカウントをアップデートする間隔
    static let timeCountUpdateDurationMillisec: Int = 10
    
    // 的の見た目を変更する隠しイベントを発動するのに必要なリロードモーションの検知回数
    static let targetsAppearanceChangingLimit: Int = 20
    static let targetHitConditionPairs: Set<Set<GameObjectInfo.ObjectType>> = [
        [.target, .pistolBullet],
        [.target, .bazookaBullet]
    ]
}
