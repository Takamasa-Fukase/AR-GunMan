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
import RxSwift
import RxCocoa

class GameSceneManager: NSObject {
    
    //MARK: - Properties
    var sceneView = ARSCNView()

    // - node
    private var bulletNode: SCNNode?
    private var bazookaHitExplosion: SCNNode?
    private var jetFire: SCNNode?
    private var exploPar: SCNParticleSystem?
    private var currentWeapon: WeaponTypes?
    
    // - count
    private var explosionCount = 0

    // - nodeAnimation
    private var toggleActionInterval = 0.2
    private var lastCameraPos = SCNVector3()
    private var isPlayerRunning = false
    private var lastPlayerStatus = false
    
    // - notification
    private let _targetHit = PublishRelay<Void>()
    var targetHit: Observable<Void> {
        return _targetHit.asObservable()
    }
    
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
     - 発砲時のアニメーション実行
     - ゆらゆら＆ひゅんひゅんモーションの実行
     - 描画時のFPS移動、アニメーション削除＆再実行
     - 衝突検知時の的＆弾消し、パーティクル設置
     */

    func changeTargetsToTaimeisan() {
        
        self.sceneView.scene.rootNode.childNodes.forEach({ node in
            print("node: \(node), name: \(node.name)")
            if node.name == "target" {
                print("targetだった")
                while node.childNode(withName: "torus", recursively: false) != nil {
                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
                    print("torusを削除")
                }
                
                node.childNode(withName: "sphere", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "taimei4.jpg")
                
            }else {
                print("targetじゃない")
            }
        })
        AudioUtil.playSound(of: .kyuiin)
    }
    
    func gunnerShakeAnimationNormal() {
        
        //銃の先端が上に跳ね上がる回転のアニメーション
        let rotate = SCNAction.rotateBy(x: -0.1779697224, y: 0.0159312604, z: -0.1784194, duration: 1.2)
        //↑の逆（下に戻る回転）
        let rotateReverse = rotate.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let rotateAction = SCNAction.sequence([rotate, rotateReverse])
        
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.01, z: 0, duration: 0.8)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let moveAction = SCNAction.sequence([moveUp, moveDown])
        
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.group([rotateAction, moveAction])
        
        //↑を永遠繰り返すアニメーション
        let gunnerShakeAction = SCNAction.repeatForever(conbineAction)
        
        //実行
        sceneView.scene.rootNode.childNode(withName: "parentNode", recursively: false)?.childNode(withName: "M1911", recursively: false)?.runAction(gunnerShakeAction)
    }
    
    func gunnerShakeAnimationRunning() {
        //銃が右に移動するアニメーション
        let moveRight = SCNAction.moveBy(x: 0.03, y: 0, z: 0, duration: 0.3)
        //↑の逆（左に移動）
        let moveLeft = moveRight.reversed()
        
        //銃が垂直に持ち上がるアニメーション
        let moveUp = SCNAction.moveBy(x: 0, y: 0.02, z: 0, duration: 0.15)
        //↑の逆（垂直に下に下がる）
        let moveDown = moveUp.reversed()
        //上下交互
        let upAndDown = SCNAction.sequence([moveUp, moveDown])
        
        let rightAndUpDown = SCNAction.group([moveRight, upAndDown])
        let LeftAndUpDown = SCNAction.group([moveLeft, upAndDown])
        
        //回転と上下移動のアニメーションを並列に同時実行するアニメーション(それぞれのdurationをずらすことによって不規則な動き感を出している)
        let conbineAction = SCNAction.sequence([rightAndUpDown, LeftAndUpDown])
        
        //↑を永遠繰り返すアニメーション
        let repeatAction = SCNAction.repeatForever(conbineAction)
        
        //実行
        switch currentWeapon {
        case .pistol:
            sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(repeatAction)
        default: break
        }
    }
    
    func shootingAnimation() {
        //発砲時に銃の先端が上に跳ね上がる回転のアニメーション
        let rotateAction = SCNAction.rotateBy(x: -0.9711356901, y: -0.08854044763, z: -1.013580166, duration: 0.1)
        //↑の逆（下に戻る回転）
        let reverse = rotateAction.reversed()
        //上下のアニメーションを直列に実行するアニメーション
        let shoot = SCNAction.sequence([rotateAction, reverse])
        
        //実行
        sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false)?.runAction(shoot)
    }
}

extension GameSceneManager: ARSCNViewDelegate {
    //常に更新され続けるdelegateメソッド
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        var nodeName: String {
            switch currentWeapon {
            case .pistol:
                return "parent"
            case .bazooka:
                return "bazookaParent"
            default:
                return ""
            }
        }
        guard let weaponNode = sceneView.scene.rootNode.childNode(withName: nodeName, recursively: false) else {
            return
        }
        //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
        SceneNodeUtil.positionAsSameAsCamera(weaponNode, scnView: sceneView)
        
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
        toggleActionInterval -= 0.02
    }
}

extension GameSceneManager: SCNPhysicsContactDelegate {
    //衝突検知時に呼ばれる
    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let nodeA = contact.nodeA
        let nodeB = contact.nodeB
        
        if (nodeA.name == "bullet" && nodeB.name == "target") || (nodeB.name == "bullet" && nodeA.name == "target") {
            print("当たった")
            nodeA.removeFromParentNode()
            nodeB.removeFromParentNode()
            
            if currentWeapon == .bazooka {
                if let first = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
                    first.birthRate = 300
                    first.loops = false
                }
            }
            
            //ヒットしたという通知をVC経由でsubscribeさせ、statusManagerに伝達する
            _targetHit.accept(Void())
        }
    }
}
