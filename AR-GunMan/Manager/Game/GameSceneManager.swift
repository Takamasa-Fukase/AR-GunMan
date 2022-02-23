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
    private var pistolParentNode = SCNNode()
    private var bazookaParentNode = SCNNode()
    private var currentWeapon: WeaponTypes = .pistol
    
    // - count
    private var explosionCount = 0

    // - nodeAnimation
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
        //各武器をセットアップ
        setupPistolNode()
        setupBazookaNode()
        //ターゲットをランダムな位置に配置
        addTarget()
    }
    
    //指定された武器を表示
    func showWeapon(_ type: WeaponTypes) {
        currentWeapon = type
        switchWeapon()
    }
    
    //現在選択中の武器の発砲に関わるアニメーション処理などを実行
    func fireWeapon() {
        addBullet()
        shootBullet()
        pistolNode().runAction(SceneAnimationUtil.shootingMotion())
    }

    func changeTargetsToTaimeisan() {
        sceneView.scene.rootNode.childNodes.forEach({ node in
            if node.name == GameConst.targetNodeName {
                while node.childNode(withName: "torus", recursively: false) != nil {
                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
                    //ドーナツ型の白い線のパーツを削除
                    print("torusを削除")
                }
                node.childNode(withName: "sphere", recursively: false)?.geometry?.firstMaterial?.diffuse.contents = GameConst.taimeiSanImage
            }
        })
    }
    
    func setupBazookaHitExplosion(type: ParticleSystemTypes) {
        //ロケラン名中時の爆発
        //art.scnassets配下のファイル名までのパスを記載
        let explosionScene = SCNScene(named: GameConst.getParticleSystemScnAssetsPath(type))
        
        //注意: withNameにはscnのファイル名ではなく、Identity欄のnameを指定する
        if let explosion = (explosionScene?.rootNode.childNode(withName: type.rawValue, recursively: false)) {
            
            //座標を指定したい場合はここで設定（↓ではカメラ位置よりも50cm前方を指定）
            let cameraPos = SceneNodeUtil.getCameraPosition(sceneView)
            explosion.position = SCNVector3(x: cameraPos.x, y: cameraPos.y, z: cameraPos.z - 0.5)
            
            //画面に反映
            self.sceneView.scene.rootNode.addChildNode(explosion)
        }
                
        if let particleSystem = sceneView.scene.rootNode.childNode(withName: "\(type.rawValue)\(explosionCount)", recursively: false)?.particleSystems?.first  {
            
            particleSystem.birthRate = 300
            particleSystem.loops = false
        }
        exploPar = bazookaHitExplosion?.particleSystems?.first ?? SCNParticleSystem()
    }
    
    func handlePlayerAnimation() {
        //前回チェック時(0.2秒毎)からの端末の移動距離が15cm以上であれば走っていると判定し、武器を激しく揺らす
        let currentPos = SceneNodeUtil.getCameraPosition(sceneView)
        isPlayerRunning = SceneNodeUtil.isPlayerRunning(pos1: currentPos, pos2: lastCameraPos)
                
        if isPlayerRunning != lastPlayerStatus {
            
            pistolNode().removeAllActions()
            //一度初期状態に戻す
            pistolNode().position = SCNVector3(0.17, -0.197, -0.584)
            pistolNode().eulerAngles = SCNVector3(-1.4382625, 1.3017014, -2.9517007)
            
            if isPlayerRunning {
                pistolNode().runAction(SceneAnimationUtil.gunnerShakeAnimationRunning())
            }else {
                pistolNode().runAction(SceneAnimationUtil.gunnerShakeAnimationNormal())
            }
        }
        lastCameraPos = SceneNodeUtil.getCameraPosition(sceneView)
        lastPlayerStatus = isPlayerRunning
    }
    
    //MARK: - Private Methods
    private func setupPistolNode() {
        pistolParentNode = SceneNodeUtil.loadScnFile(of: "art.scnassets/Weapon/Pistol/M1911_a.scn", nodeName: "parent")
        SceneNodeUtil.addBillboardConstraint(pistolParentNode)
        pistolParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
    }
    
    private func pistolNode() -> SCNNode {
        return pistolParentNode.childNode(withName: "M1911_a", recursively: false) ?? SCNNode()
    }
    
    private func setupBazookaNode() {
        bazookaParentNode = SceneNodeUtil.loadScnFile(of: "art.scnassets/Weapon/RocketLauncher/bazooka2.scn", nodeName: "bazookaParent")
        SceneNodeUtil.addBillboardConstraint(bazookaParentNode)
        bazookaParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
    }
    
    private func switchWeapon() {
        SceneNodeUtil.removeOtherWeapon(except: currentWeapon, scnView: sceneView)
        switch currentWeapon {
        case .pistol:
            sceneView.scene.rootNode.addChildNode(pistolParentNode)
        case .bazooka:
            sceneView.scene.rootNode.addChildNode(bazookaParentNode)
        }
    }

    //弾ノードを設置
    private func addBullet() {
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        
        sphere.firstMaterial?.diffuse.contents = customYellow
        bulletNode = SCNNode(geometry: sphere)
        guard let bulletNode = bulletNode else {return}
        bulletNode.name = "bullet"
        bulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        bulletNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        
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
        bulletNode?.runAction(
            SceneAnimationUtil.shootBulletToCenterOfCamera(sceneView.pointOfView), completionHandler: {
                self.bulletNode?.removeFromParentNode()
            }
        )
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
            for _ in 0..<GameConst.targetCount {
                let clonedTargetNode = originalTargetNode.clone()
                clonedTargetNode.position = SceneNodeUtil.getRandomTargetPosition()
                SceneNodeUtil.addBillboardConstraint(clonedTargetNode)
                self.sceneView.scene.rootNode.addChildNode(clonedTargetNode)
            }
        }
    }
    
    private func keepWeaponInFPSPosition() {
        var weaponParentNode: SCNNode {
            switch currentWeapon {
            case .pistol:
                return pistolParentNode
            case .bazooka:
                return bazookaParentNode
            }
        }
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
    }
    
    private func isTargetHit(contact: SCNPhysicsContact) -> Bool {
        return (contact.nodeA.name == "bullet" && contact.nodeB.name == "target") ||
            (contact.nodeB.name == "bullet" && contact.nodeA.name == "target")
    }
    
    private func excuteExplosion() {
        if let first = sceneView.scene.rootNode.childNode(withName: "bazookaHitExplosion\(explosionCount)", recursively: false)?.particleSystems?.first  {
            first.birthRate = 300
            first.loops = false
        }
    }
}

extension GameSceneManager: ARSCNViewDelegate {
    //常に更新され続けるdelegateメソッド
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
        keepWeaponInFPSPosition()
    }
}

extension GameSceneManager: SCNPhysicsContactDelegate {
    //衝突検知時に呼ばれる
    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if isTargetHit(contact: contact) {
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
            
            if currentWeapon == .bazooka {
                excuteExplosion()
            }
            //ヒットしたという通知をVC経由でsubscribeさせ、statusManagerに伝達する
            _targetHit.accept(Void())
        }
    }
}
