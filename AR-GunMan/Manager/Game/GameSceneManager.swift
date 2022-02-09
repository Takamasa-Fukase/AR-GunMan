////
////  GameSceneManager.swift
////  AR-GunMan
////
////  Created by ウルトラ深瀬 on 2022/02/02.
////
//
//import Foundation
//import ARKit
//import SceneKit
//
//class GameSceneManager: NSObject {
//
//    //node
//    var bulletNode: SCNNode?
//    var bazookaHitExplosion: SCNNode?
//    var jetFire: SCNNode?
//    var targetNode: SCNNode?
//    var exploPar: SCNParticleSystem?
//
//    /*
//     - 泰明さんにテクスチャを切り替え
//     - 初回に一回だけ的を50個設置
//     - 球を発射（武器共通）
//     - 球を設置（武器共通）
//     - 武器を画面に設置（共通化する）
//     - 発砲時のアニメーション実行
//     - ゆらゆら＆ひゅんひゅんモーションの実行
//     - 描画時のFPS移動、アニメーション削除＆再実行
//     - 衝突検知時の的＆弾消し、パーティクル設置
//     */
//}
//
//extension GameSceneManager: ARSCNViewDelegate {
//    //常に更新され続けるdelegateメソッド
//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//        //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
//        if let pistol = sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
//            pistol.position = sceneView.pointOfView?.position ?? SCNVector3()
//        }
//        if let bazooka = sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
//            bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
//        }
//        if let rifle = sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
//            rifle.position = sceneView.pointOfView?.position ?? SCNVector3()
//        }
//
//        if toggleActionInterval <= 0 {
//            guard let currentPos = sceneView.pointOfView?.position else {return}
//            let diff = SCNVector3Make(lastCameraPos.x - currentPos.x, lastCameraPos.y - currentPos.y, lastCameraPos.z - currentPos.z)
//            let distance = sqrt((diff.x * diff.x) + (diff.y * diff.y) + (diff.z * diff.z))
////            print("0.2秒前からの移動距離: \(String(format: "%.1f", distance))m")
//
//            isPlayerRunning = (distance >= 0.15)
//
//            if isPlayerRunning != lastPlayerStatus {
//
//                switch currentWeapon {
//                case .pistol:
//                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.removeAllActions()
//                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.position = SCNVector3(0.17, -0.197, -0.584)
//                    sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.eulerAngles = SCNVector3(-1.4382625, 1.3017014, -2.9517007)
//                case .rifle:
//
//                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.removeAllActions()
//                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.position = SCNVector3(0, 0, 0)
//                    sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.eulerAngles = SCNVector3(0, 0, 0)
//
//                default: break
//                }
//
//                isPlayerRunning ? gunnerShakeAnimationRunning() : gunnerShakeAnimationNormal()
//            }
//            self.toggleActionInterval = 0.2
//            lastCameraPos = sceneView.pointOfView?.position ?? SCNVector3()
//            lastPlayerStatus = isPlayerRunning
//        }
//        toggleActionInterval -= 0.02
//    }
//}
//
//extension GameSceneManager: SCNPhysicsContactDelegate {
//    //衝突検知時に呼ばれる
//    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
//    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
//        let nodeA = contact.nodeA
//        let nodeB = contact.nodeB
//
//        if (nodeA.name == "bullet" && nodeB.name == "target") || (nodeB.name == "bullet" && nodeA.name == "target") {
//            print("当たった")
//            AudioUtil.playSound(of: .headShot)
//            nodeA.removeFromParentNode()
//            nodeB.removeFromParentNode()
//
//            if currentWeapon == .bazooka {
//                AudioUtil.playSound(of: .bazookaHit)
//
//                if let first = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
//
//                    first.birthRate = 300
//                    first.loops = false
//
//                }
//            }
//
//            switch currentWeapon {
//            case .pistol:
//                pistolPoint += 5
//            case .bazooka:
//                bazookaPoint += 12
//            default:
//                break
//            }
//
//            targetCount -= 1
//        }
//    }
//}
