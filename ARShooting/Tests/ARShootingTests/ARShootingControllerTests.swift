//
//  ARShootingControllerTests.swift
//  
//
//  Created by ウルトラ深瀬 on 20/12/24.
//

import XCTest
@testable import ARShooting

final class ARShootingControllerTests: XCTestCase {
    private var arController: ARShootingController!
    private var sceneManagerStub: SceneManagerStub!
    
    override func setUpWithError() throws {
        sceneManagerStub = .init()
        arController = .init(sceneManager: sceneManagerStub)
    }

    override func tearDownWithError() throws {
        sceneManagerStub = nil
        arController = nil
    }
    
    func test_targetHit() {
        XCTAssertTrue(arController.targetHit == nil)
        XCTAssertTrue(sceneManagerStub.targetHit == nil)
        
        var isARControllerTargetHitCalled = false
        
        arController.targetHit = {
            isARControllerTargetHitCalled = true
        }
        
        XCTAssertTrue(sceneManagerStub.targetHit != nil)
        
        XCTAssertEqual(isARControllerTargetHitCalled, false)
        sceneManagerStub.targetHit?()
        XCTAssertEqual(isARControllerTargetHitCalled, true)
    }
    
    func test_view() {
        let view = arController.view as! SceneViewRepresentable
        XCTAssertEqual(view.getView(), sceneManagerStub.dummySceneView)
    }
    
    func test_runSession() {
        XCTAssertEqual(sceneManagerStub.runSessionCalledCount, 0)
        arController.runSession()
        XCTAssertEqual(sceneManagerStub.runSessionCalledCount, 1)
    }
    
    func test_pauseSession() {
        XCTAssertEqual(sceneManagerStub.pauseSessionCalledCount, 0)
        arController.pauseSession()
        XCTAssertEqual(sceneManagerStub.pauseSessionCalledCount, 1)
    }
    
    func test_showWeaponObject() {
        XCTAssertEqual(sceneManagerStub.showWeaponObjectCalledValues, [])
        arController.showWeaponObject(weaponId: 100)
        XCTAssertEqual(sceneManagerStub.showWeaponObjectCalledValues, [100])
    }
    
    func test_renderWeaponFiring() {
        XCTAssertEqual(sceneManagerStub.renderWeaponFiringCalledCount, 0)
        arController.renderWeaponFiring()
        XCTAssertEqual(sceneManagerStub.renderWeaponFiringCalledCount, 1)
    }
    
    func test_changeTargetsAppearance() {
        XCTAssertEqual(sceneManagerStub.changeTargetsAppearanceCalledValues, [])
        arController.changeTargetsAppearance(to: "test_image")
        XCTAssertEqual(sceneManagerStub.changeTargetsAppearanceCalledValues, ["test_image"])
    }
}
