//
//  ARShootingControllerTests.swift
//  ARShootingTests
//
//  Created by ウルトラ深瀬 on 20/12/24.
//

import XCTest
@testable import ARShooting

final class ARShootingControllerTests: XCTestCase {
    private var arController: ARShootingController!
    private var sceneManagerMock: SceneManagerMock!
    
    override func setUpWithError() throws {
        sceneManagerMock = .init()
        arController = .init(sceneManager: sceneManagerMock)
    }

    override func tearDownWithError() throws {
        sceneManagerMock = nil
        arController = nil
    }
    
    func test_targetHit() {
        XCTAssertTrue(arController.targetHit == nil)
        XCTAssertTrue(sceneManagerMock.targetHit == nil)
        
        var isARControllerTargetHitCalled = false
        
        arController.targetHit = {
            isARControllerTargetHitCalled = true
        }
        
        XCTAssertTrue(sceneManagerMock.targetHit != nil)
        
        XCTAssertEqual(isARControllerTargetHitCalled, false)
        sceneManagerMock.targetHit?()
        XCTAssertEqual(isARControllerTargetHitCalled, true)
    }
    
    func test_view() {
        let view = arController.view as! SceneViewRepresentable
        XCTAssertEqual(view.getView(), sceneManagerMock.dummySceneView)
    }
    
    func test_runSession() {
        XCTAssertEqual(sceneManagerMock.runSessionCalledCount, 0)
        arController.runSession()
        XCTAssertEqual(sceneManagerMock.runSessionCalledCount, 1)
    }
    
    func test_pauseSession() {
        XCTAssertEqual(sceneManagerMock.pauseSessionCalledCount, 0)
        arController.pauseSession()
        XCTAssertEqual(sceneManagerMock.pauseSessionCalledCount, 1)
    }
    
    func test_showWeaponObject() {
        XCTAssertEqual(sceneManagerMock.showWeaponObjectCalledValues, [])
        arController.showWeaponObject(weaponId: 100)
        XCTAssertEqual(sceneManagerMock.showWeaponObjectCalledValues, [100])
    }
    
    func test_renderWeaponFiring() {
        XCTAssertEqual(sceneManagerMock.renderWeaponFiringCalledCount, 0)
        arController.renderWeaponFiring()
        XCTAssertEqual(sceneManagerMock.renderWeaponFiringCalledCount, 1)
    }
    
    func test_changeTargetsAppearance() {
        XCTAssertEqual(sceneManagerMock.changeTargetsAppearanceCalledValues, [])
        arController.changeTargetsAppearance(to: "test_image")
        XCTAssertEqual(sceneManagerMock.changeTargetsAppearanceCalledValues, ["test_image"])
    }
}
