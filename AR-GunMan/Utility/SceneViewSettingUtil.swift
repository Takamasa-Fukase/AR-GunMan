//
//  SceneViewSettingUtil.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/13.
//

import Foundation
import ARKit
import SceneKit

class SceneViewSettingUtil {
    
    static func setupSceneView(_ sceneView: ARSCNView,
                               sceneViewDelegate: ARSCNViewDelegate,
                               physicContactDelegate: SCNPhysicsContactDelegate) {
        //シーンの作成
        sceneView.scene = SCNScene()
        //光源の有効化
        sceneView.autoenablesDefaultLighting = true;
        //ARSCNViewデリゲートの指定
        sceneView.delegate = sceneViewDelegate
        //衝突検知のためのDelegate設定
        sceneView.scene.physicsWorld.contactDelegate = physicContactDelegate
    }
    
    static func startSession(_ sceneView: ARSCNView) {
        //コンフィギュレーションの生成
        let configuration = ARWorldTrackingConfiguration()
        //平面検出の有効化
        configuration.planeDetection = .horizontal
        //セッションの開始
        sceneView.session.run(configuration)
    }
    
    static func pauseSession(_ sceneView: ARSCNView) {
        //セッションの一時停止
        sceneView.session.pause()
    }
}
