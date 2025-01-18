//
//  TestData.swift
//
//
//  Created by ウルトラ深瀬 on 21/12/24.
//

import Foundation
@testable import WeaponControlMotion

// MARK: 発射モーション判定の加速度条件の境界値データ
// 条件: 合成値 >= 1.5
//  - 合成値が 1.501264 になるので成功
let 発射モーション加速度成功データ = DummyCMAccelerometerData(x: 0, y: 1.0, z: 0.708)
//  - 合成値が 1.499849 になるので失敗
let 発射モーション加速度失敗データ = DummyCMAccelerometerData(x: 0, y: 1.0, z: 0.707)


// MARK: 発射モーション判定のジャイロ条件の境界値データ
// 条件: 合成値 < 10
//  - 合成値が 9.998244 になるので成功
let 発射モーションジャイロ成功データ = DummyCMGyroData(x: 0, y: 0, z: 3.162)
//  - 合成値が 10.004568 になるので失敗
let 発射モーションジャイロ失敗データ = DummyCMGyroData(x: 0, y: 0, z: 3.163)


// MARK: リロードモーション判定のジャイロ条件の境界値データ
// 条件: 合成値 >= 10
//  - 合成値が 10.004568 になるので成功
let リロードモーションジャイロ成功データ = DummyCMGyroData(x: 0, y: 0, z: 3.163)
//  - 合成値が 9.998244 になるので失敗
let リロードモーションジャイロ失敗データ = DummyCMGyroData(x: 0, y: 0, z: 3.162)


// MARK: テストケース作成・更新時に使用する
func checkTestDataCompositeValues() {
    print("\n\n=== checkTestDataCompositeValues開始 ===\n")
    
    let compositeOf発射モーション加速度成功データ = CompositeCalculator.getCompositeValue(
        x: 発射モーション加速度成功データ.acceleration.x,
        y: 発射モーション加速度成功データ.acceleration.y,
        z: 発射モーション加速度成功データ.acceleration.z
    )
    print("compositeOf発射モーション加速度成功データ: \(compositeOf発射モーション加速度成功データ)")
    
    let compositeOf発射モーション加速度失敗データ = CompositeCalculator.getCompositeValue(
        x: 発射モーション加速度失敗データ.acceleration.x,
        y: 発射モーション加速度失敗データ.acceleration.y,
        z: 発射モーション加速度失敗データ.acceleration.z
    )
    print("compositeOf発射モーション加速度失敗データ: \(compositeOf発射モーション加速度失敗データ)")
    
    let compositeOf発射モーションジャイロ成功データ = CompositeCalculator.getCompositeValue(
        x: 発射モーションジャイロ成功データ.rotationRate.x,
        y: 発射モーションジャイロ成功データ.rotationRate.y,
        z: 発射モーションジャイロ成功データ.rotationRate.z
    )
    print("compositeOf発射モーションジャイロ成功データ: \(compositeOf発射モーションジャイロ成功データ)")
    
    let compositeOf発射モーションジャイロ失敗データ = CompositeCalculator.getCompositeValue(
        x: 発射モーションジャイロ失敗データ.rotationRate.x,
        y: 発射モーションジャイロ失敗データ.rotationRate.y,
        z: 発射モーションジャイロ失敗データ.rotationRate.z
    )
    print("compositeOf発射モーションジャイロ失敗データ: \(compositeOf発射モーションジャイロ失敗データ)")
    
    let compositeOfリロードモーションジャイロ成功データ = CompositeCalculator.getCompositeValue(
        x: リロードモーションジャイロ成功データ.rotationRate.x,
        y: リロードモーションジャイロ成功データ.rotationRate.y,
        z: リロードモーションジャイロ成功データ.rotationRate.z
    )
    print("compositeOfリロードモーションジャイロ成功データ: \(compositeOfリロードモーションジャイロ成功データ)")
    
    let compositeOfリロードモーションジャイロ失敗データ = CompositeCalculator.getCompositeValue(
        x: リロードモーションジャイロ失敗データ.rotationRate.x,
        y: リロードモーションジャイロ失敗データ.rotationRate.y,
        z: リロードモーションジャイロ失敗データ.rotationRate.z
    )
    print("compositeOfリロードモーションジャイロ失敗データ: \(compositeOfリロードモーションジャイロ失敗データ)")
    
    print("\n=== checkTestDataCompositeValues終了 ===\n\n")
}
