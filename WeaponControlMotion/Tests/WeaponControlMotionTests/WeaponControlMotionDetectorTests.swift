//
//  WeaponControlMotionDetectorTests.swift
//  
//
//  Created by ウルトラ深瀬 on 20/12/24.
//

import XCTest
import CoreMotion
@testable import WeaponControlMotion

final class WeaponControlMotionDetectorTests: XCTestCase {
    private var motionDetector: WeaponControlMotionDetector!
    private var coreMotionManagerStub: CoreMotionManagerStub!

    override func setUpWithError() throws {
        coreMotionManagerStub = .init()
        motionDetector = .init(coreMotionManager: coreMotionManagerStub)
    }

    override func tearDownWithError() throws {
        coreMotionManagerStub = nil
        motionDetector = nil
    }
    
    func test_init() {
        XCTAssertEqual(coreMotionManagerStub.accelerometerUpdateInterval, 0.2)
        XCTAssertEqual(coreMotionManagerStub.gyroUpdateInterval, 0.2)
    }
    
    func test_startDetection() {
        XCTAssertEqual(coreMotionManagerStub.startAccelerometerUpdatesCalledCount, 0)
        XCTAssertEqual(coreMotionManagerStub.startGyroUpdatesCalledCount, 0)
        motionDetector.startDetection()
        XCTAssertEqual(coreMotionManagerStub.startAccelerometerUpdatesCalledCount, 1)
        XCTAssertEqual(coreMotionManagerStub.startGyroUpdatesCalledCount, 1)
    }
    
    func test_stopDetection() {
        XCTAssertEqual(coreMotionManagerStub.stopAccelerometerUpdatesCalledCount, 0)
        XCTAssertEqual(coreMotionManagerStub.stopGyroUpdatesCalledCount, 0)
        motionDetector.stopDetection()
        XCTAssertEqual(coreMotionManagerStub.stopAccelerometerUpdatesCalledCount, 1)
        XCTAssertEqual(coreMotionManagerStub.stopGyroUpdatesCalledCount, 1)
    }
    
    func test_fireMotionDetected() {
        // MARK: 事前準備
        
        var isFireMotionDetectedCalled = false
        // 発射モーションが検知された時にフラグをtrueにする
        motionDetector.fireMotionDetected = {
            isFireMotionDetectedCalled = true
        }
        // モーション検知開始
        motionDetector.startDetection()
        
        
        // MARK: ジャイロと加速度の両方が成功データの場合にfireMotionDetectedが呼ばれることをテスト
        
        // 一度falseにリセット
        isFireMotionDetectedCalled = false
        XCTAssertFalse(isFireMotionDetectedCalled)
        // ジャイロの最新値が使用されるため、先にジャイロハンドラーに成功データを流しておく
        coreMotionManagerStub.gyroHander?(発射モーションジャイロ成功データ, nil)
        // 加速度ハンドラーに成功データを流す
        coreMotionManagerStub.accelerometerHander?(発射モーション加速度成功データ, nil)
        XCTAssertTrue(isFireMotionDetectedCalled)
        
        
        // MARK: ジャイロが成功データで加速度が失敗データの場合にfireMotionDetectedが呼ばれ無いことをテスト
        
        // 一度falseにリセット
        isFireMotionDetectedCalled = false
        XCTAssertFalse(isFireMotionDetectedCalled)
        // ジャイロの最新値が使用されるため、先にジャイロハンドラーに成功データを流しておく
        coreMotionManagerStub.gyroHander?(発射モーションジャイロ成功データ, nil)
        // 加速度ハンドラーに失敗データを流す
        coreMotionManagerStub.accelerometerHander?(発射モーション加速度失敗データ, nil)
        XCTAssertFalse(isFireMotionDetectedCalled)
        
        
        // MARK: ジャイロが失敗データで加速度が成功データの場合にfireMotionDetectedが呼ばれ無いことをテスト
        
        // 一度falseにリセット
        isFireMotionDetectedCalled = false
        XCTAssertFalse(isFireMotionDetectedCalled)
        // ジャイロの最新値が使用されるため、先にジャイロハンドラーに失敗データを流しておく
        coreMotionManagerStub.gyroHander?(発射モーションジャイロ失敗データ, nil)
        // 加速度ハンドラーに成功データを流す
        coreMotionManagerStub.accelerometerHander?(発射モーション加速度成功データ, nil)
        XCTAssertFalse(isFireMotionDetectedCalled)
        
        
        // MARK: ジャイロと加速度の両方が失敗データの場合にfireMotionDetectedが呼ばれ無いことをテスト
        
        // 一度falseにリセット
        isFireMotionDetectedCalled = false
        XCTAssertFalse(isFireMotionDetectedCalled)
        // ジャイロの最新値が使用されるため、先にジャイロハンドラーに失敗データを流しておく
        coreMotionManagerStub.gyroHander?(発射モーションジャイロ失敗データ, nil)
        // 加速度ハンドラーに失敗データを流す
        coreMotionManagerStub.accelerometerHander?(発射モーション加速度失敗データ, nil)
        XCTAssertFalse(isFireMotionDetectedCalled)
        
        
        // MARK: 加速度とジャイロが成功データと一緒にエラーも流れてきた場合にfireMotionDetectedが呼ばれ無いことをテスト
        
        // 一度falseにリセット
        isFireMotionDetectedCalled = false
        XCTAssertFalse(isFireMotionDetectedCalled)
        // ジャイロの最新値が使用されるため、先にジャイロハンドラーに成功データと一緒にエラーを流す
        coreMotionManagerStub.gyroHander?(発射モーションジャイロ成功データ, CustomError.other(message: "ジャイロダミーエラー"))
        // 加速度ハンドラーに成功データと一緒にエラーを流す
        coreMotionManagerStub.accelerometerHander?(発射モーション加速度成功データ, CustomError.other(message: "加速度ダミーエラー"))
        XCTAssertFalse(isFireMotionDetectedCalled)
    }
    
    func test_reloadMotionDetected() {
        // MARK: 事前準備
        
        var isReloadMotionDetectedCalled = false
        // リロードモーションが検知された時にフラグをtrueにする
        motionDetector.reloadMotionDetected = {
            isReloadMotionDetectedCalled = true
        }
        // モーション検知開始
        motionDetector.startDetection()
        
        
        // MARK: ジャイロが成功データの場合にreloadMotionDetectedが呼ばれることをテスト
        
        // 一度falseにリセット
        isReloadMotionDetectedCalled = false
        XCTAssertFalse(isReloadMotionDetectedCalled)
        // ジャイロハンドラーに成功データを流す
        coreMotionManagerStub.gyroHander?(リロードモーションジャイロ成功データ, nil)
        XCTAssertTrue(isReloadMotionDetectedCalled)
        
        
        // MARK: ジャイロが失敗データの場合にreloadMotionDetectedが呼ばれ無いことをテスト
        
        // 一度falseにリセット
        isReloadMotionDetectedCalled = false
        XCTAssertFalse(isReloadMotionDetectedCalled)
        // ジャイロハンドラーに失敗データを流す
        coreMotionManagerStub.gyroHander?(リロードモーションジャイロ失敗データ, nil)
        XCTAssertFalse(isReloadMotionDetectedCalled)
        
        
        // MARK: ジャイロが成功データと一緒にエラーも流れてきた場合にfireMotionDetectedが呼ばれ無いことをテスト
        
        // 一度falseにリセット
        isReloadMotionDetectedCalled = false
        XCTAssertFalse(isReloadMotionDetectedCalled)
        // ジャイロハンドラーに成功データと一緒にエラーを流す
        coreMotionManagerStub.gyroHander?(リロードモーションジャイロ成功データ, CustomError.other(message: "ジャイロダミーエラー"))
        XCTAssertFalse(isReloadMotionDetectedCalled)
    }
}
