//
//  GameSceneManager.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 2022/02/02.
//
//
import Foundation
import ARKit
import SceneKit

class GameSceneManager: NSObject {
    
    //MARK: - Properties
    var sceneView = ARSCNView()

    //node
    var bulletNode: SCNNode?
    var bazookaHitExplosion: SCNNode?
    var jetFire: SCNNode?
    var exploPar: SCNParticleSystem?
    
    //MARK: - Methods
    override init() {
        super.init()
        
        //SceneViewをセットアップ
        SceneViewSettingUtil.setupSceneView(sceneView, sceneViewDelegate: self, physicContactDelegate: self)
        //ターゲットをランダムな位置に配置
        addTarget()
        SceneNodeUtil.addWeapon(of: .pistol, scnView: sceneView)
    }
    
    //弾ノードを設置
    func addBullet() {
        guard let cameraPos = sceneView.pointOfView?.position else {return}
        
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        
        sphere.firstMaterial?.diffuse.contents = customYellow
        bulletNode = SCNNode(geometry: sphere)
        guard let bulletNode = bulletNode else {return}
        bulletNode.name = "bullet"
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        bulletNode.position = cameraPos
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        bulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        bulletNode.physicsBody?.contactTestBitMask = 1
        bulletNode.physicsBody?.isAffectedByGravity = false
        sceneView.scene.rootNode.addChildNode(bulletNode)
        
        print("弾を設置")
    }
    
    //弾ノードを発射
    func shootBullet() {
        guard let camera = sceneView.pointOfView else {return}
        let targetPosCamera = SCNVector3(x: camera.position.x, y: camera.position.y, z: camera.position.z - 10)
        //カメラ座標をワールド座標に変換
        let target = camera.convertPosition(targetPosCamera, to: nil)
        let action = SCNAction.move(to: target, duration: TimeInterval(1))
        bulletNode?.runAction(action, completionHandler: {
            self.bulletNode?.removeFromParentNode()
        })
        
        print("弾を発射")
    }
    
    private func createOriginalTargetNode() -> SCNNode {
        let originalTargetNode = SceneNodeUtil.loadScnFile(of: "art.scnassets/target.scn", nodeName: "target")
        originalTargetNode.scale = SCNVector3(0.3, 0.3, 0.3)
        
        let targetNodeGeometry = (originalTargetNode.childNode(withName: "sphere", recursively: false)?.geometry) ?? SCNGeometry()
        
        //MARK: - 当たり判定の肝2つ
        //①形状はラップしてる空のNodeではなく何か1つgeometryを持っているものにするを指定する
        //②当たり判定のscaleはoptions: [SCNPhysicsShape.Option.scale: SCNVector3]で明示的に設定する（大体①のgeometryの元となっているNodeのscaleを代入すれば等しい当たり判定になる）
        let shape = SCNPhysicsShape(geometry: targetNodeGeometry, options: [SCNPhysicsShape.Option.scale: originalTargetNode.scale])
        
        //当たり判定用のphysicBodyを追加
        originalTargetNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        originalTargetNode.physicsBody?.isAffectedByGravity = false
        
        return originalTargetNode
    }
      
    //的ノードをランダムな座標に設置
    private func addTarget() {
        //メモリ節約のために１つだけオリジナルを生成し、それをクローンして使う
        let originalTargetNode = createOriginalTargetNode()
        
        DispatchQueue.main.async {
            for _ in 0..<Const.targetCount {
                let clonedTargetNode = originalTargetNode.clone()
                clonedTargetNode.position = SceneNodeUtil.getRandomTargetPosition()
                SceneNodeUtil.addBillboardConstraint(clonedTargetNode)
                self.sceneView.scene.rootNode.addChildNode(clonedTargetNode)
            }
        }
    }
    
    
    /*
     - 泰明さんにテクスチャを切り替え
     - 初回に一回だけ的を50個設置
     - 球を発射（武器共通）
     - 球を設置（武器共通）
     - 武器を画面に設置（共通化する）
     - 発砲時のアニメーション実行
     - ゆらゆら＆ひゅんひゅんモーションの実行
     - 描画時のFPS移動、アニメーション削除＆再実行
     - 衝突検知時の的＆弾消し、パーティクル設置
     */

    
}

extension GameSceneManager: ARSCNViewDelegate {
    //常に更新され続けるdelegateメソッド
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
    
    /* //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
     if let pistol = sceneView.scene.rootNode.childNode(withName: "parent", recursively: false) {
         pistol.position = sceneView.pointOfView?.position ?? SCNVector3()
     }
     if let bazooka = sceneView.scene.rootNode.childNode(withName: "bazookaParent", recursively: false) {
         bazooka.position = sceneView.pointOfView?.position ?? SCNVector3()
     }
     if let rifle = sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false) {
         rifle.position = sceneView.pointOfView?.position ?? SCNVector3()
     }

     if toggleActionInterval <= 0 {
         guard let currentPos = sceneView.pointOfView?.position else {return}
         let diff = SCNVector3Make(lastCameraPos.x - currentPos.x, lastCameraPos.y - currentPos.y, lastCameraPos.z - currentPos.z)
         let distance = sqrt((diff.x * diff.x) + (diff.y * diff.y) + (diff.z * diff.z))
//            print("0.2秒前からの移動距離: \(String(format: "%.1f", distance))m")

         isPlayerRunning = (distance >= 0.15)

         if isPlayerRunning != lastPlayerStatus {

             switch currentWeapon {
             case .pistol:
                 sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.removeAllActions()
                 sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.position = SCNVector3(0.17, -0.197, -0.584)
                 sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.eulerAngles = SCNVector3(-1.4382625, 1.3017014, -2.9517007)
             case .rifle:

                 sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.removeAllActions()
                 sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.position = SCNVector3(0, 0, 0)
                 sceneView.scene.rootNode.childNode(withName: "AKM_parent", recursively: false)?.childNode(withName: "AKM", recursively: false)?.eulerAngles = SCNVector3(0, 0, 0)

             default: break
             }

             isPlayerRunning ? gunnerShakeAnimationRunning() : gunnerShakeAnimationNormal()
         }
         self.toggleActionInterval = 0.2
         lastCameraPos = sceneView.pointOfView?.position ?? SCNVector3()
         lastPlayerStatus = isPlayerRunning
     }
     toggleActionInterval -= 0.02*/
}

extension GameSceneManager: SCNPhysicsContactDelegate {
    //衝突検知時に呼ばれる
    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
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
    }
}
