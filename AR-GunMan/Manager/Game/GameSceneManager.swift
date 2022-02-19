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
    }
    
    //指定された武器を表示
    func showWeapon(_ type: WeaponTypes) {
        currentWeapon = type
        SceneNodeUtil.addWeapon(of: type, scnView: sceneView)
    }
    
    //現在選択中の武器の発砲に関わるアニメーション処理などを実行
    func fireWeapon() {
        addBullet()
        shootBullet()
        SceneAnimationUtil.shootingAnimation()
    }

    func changeTargetsToTaimeisan() {
        sceneView.scene.rootNode.childNodes.forEach({ node in
            if node.name == "target" {
                while node.childNode(withName: "torus", recursively: false) != nil {
                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
                    //ドーナツ型の白い線のパーツを削除
                    print("torusを削除")
                }
                node.childNode(withName: "sphere", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "taimei4.jpg")
            }
        })
    }
    
    func setupBazookaHitExplosion() {
        //ロケラン名中時の爆発
        //art.scnassets配下のファイル名までのパスを記載
        let explosionScene = SCNScene(named: "art.scnassets/ParticleSystems/ExplosionSamples/Explosion1.scn")
        
        //注意: withNameにはscnのファイル名ではなく、Identity欄のnameを指定する
        if let explosion = (explosionScene?.rootNode.childNode(withName: "Explosion1", recursively: false)) {
            
            //座標を指定したい場合はここで設定（↓ではカメラ位置よりも50cm前方を指定）
            let cameraPos = self.sceneView.pointOfView?.position ?? SCNVector3()
            explosion.position = SCNVector3(x: cameraPos.x, y: cameraPos.y, z: cameraPos.z - 0.5)
            
            //画面に反映
            self.sceneView.scene.rootNode.addChildNode(explosion)
        }
        
        //ParticleSystemへのアクセス方法
        sceneView.scene.rootNode.childNode(withName: "Explosion1", recursively: false)?.particleSystems?.first
        
        if let particleSystem = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
            
            particleSystem.birthRate = 300
            particleSystem.loops = false
        }
        exploPar = bazookaHitExplosion?.particleSystems?.first!
    }
    
    //MARK: - Private Methods
    //弾ノードを設置
    private func addBullet() {
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
    private func shootBullet() {
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
        
        guard let pistolNode = sceneView.scene.rootNode.childNode(withName: "parent", recursively: false)?.childNode(withName: "M1911_a", recursively: false) else {
            return
        }
        
        if toggleActionInterval <= 0 {
            guard let currentPos = sceneView.pointOfView?.position else {return}
            let diff = SCNVector3Make(lastCameraPos.x - currentPos.x, lastCameraPos.y - currentPos.y, lastCameraPos.z - currentPos.z)
            let distance = sqrt((diff.x * diff.x) + (diff.y * diff.y) + (diff.z * diff.z))
            //            print("0.2秒前からの移動距離: \(String(format: "%.1f", distance))m")
            
            isPlayerRunning = (distance >= 0.15)
            
            if isPlayerRunning != lastPlayerStatus {
                
                pistolNode.removeAllActions()
                pistolNode.position = SCNVector3(0.17, -0.197, -0.584)
                pistolNode.eulerAngles = SCNVector3(-1.4382625, 1.3017014, -2.9517007)
                
                if isPlayerRunning {
                    pistolNode.runAction(SceneAnimationUtil.gunnerShakeAnimationRunning())
                }else {
                    pistolNode.runAction(SceneAnimationUtil.gunnerShakeAnimationNormal())
                }
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
