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
    private var originalBulletNode = SCNNode()
    private var originalBazookaHitExplosionParticle = SCNParticleSystem()
    private var pistolParentNode = SCNNode()
    private var bazookaParentNode = SCNNode()
    private var currentWeapon: WeaponTypes = .pistol

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
        pistolParentNode = setupWeaponNode(type: .pistol)
        bazookaParentNode = setupWeaponNode(type: .bazooka)
        originalBulletNode = createOriginalBulletNode()
        originalBazookaHitExplosionParticle = createOriginalParticleSystem(type: .bazookaExplosion)
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
    private func setupWeaponNode(type: WeaponTypes) -> SCNNode {
        let weaponParentNode = SceneNodeUtil.loadScnFile(of: GameConst.getWeaponScnAssetsPath(type), nodeName: "\(type.rawValue)Parent")
        SceneNodeUtil.addBillboardConstraint(weaponParentNode)
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        return weaponParentNode
    }
    
    private func pistolNode() -> SCNNode {
        return pistolParentNode.childNode(withName: WeaponTypes.pistol.rawValue, recursively: false) ?? SCNNode()
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

    private func createOriginalBulletNode() -> SCNNode {
        let sphere: SCNGeometry = SCNSphere(radius: 0.05)
        let customYellow = UIColor(red: 253/255, green: 202/255, blue: 119/255, alpha: 1)
        
        sphere.firstMaterial?.diffuse.contents = customYellow
        originalBulletNode = SCNNode(geometry: sphere)
        originalBulletNode.name = GameConst.bulletNodeName
        originalBulletNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        originalBulletNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        
        //当たり判定用のphysicBodyを追加
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        originalBulletNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
        originalBulletNode.physicsBody?.contactTestBitMask = 1
        originalBulletNode.physicsBody?.isAffectedByGravity = false
        return originalBulletNode
    }

    //ロケラン名中時の爆発をセットアップ
    private func createOriginalParticleSystem(type: ParticleSystemTypes) -> SCNParticleSystem {
        let originalExplosionNode = SceneNodeUtil.loadScnFile(of: GameConst.getParticleSystemScnAssetsPath(type), nodeName: type.rawValue)
        return originalExplosionNode.particleSystems?.first ?? SCNParticleSystem()
    }
    
    private func createTargetHitParticleNode(type: ParticleSystemTypes) -> SCNNode {
        originalBazookaHitExplosionParticle.birthRate = 0
        originalBazookaHitExplosionParticle.loops = true
        let targetHitParticleNode = SCNNode()
        switch type {
        case .bazookaExplosion:
            targetHitParticleNode.addParticleSystem(originalBazookaHitExplosionParticle)
            return targetHitParticleNode
        }
    }

    //弾ノードを発射
    private func shootBullet() {
        //メモリ節約のため、オリジナルをクローンして使う
        let clonedBulletNode = originalBulletNode.clone()
        sceneView.scene.rootNode.addChildNode(clonedBulletNode)
        clonedBulletNode.runAction(
            SceneAnimationUtil.shootBulletToCenterOfCamera(sceneView.pointOfView), completionHandler: {
                clonedBulletNode.removeFromParentNode()
            }
        )
    }
    
    private func createOriginalTargetNode() -> SCNNode {
        let originalTargetNode = SceneNodeUtil.loadScnFile(of: GameConst.getTargetScnAssetsPath(), nodeName: GameConst.targetNodeName)
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
        return (contact.nodeA.name == GameConst.bulletNodeName && contact.nodeB.name == GameConst.targetNodeName) ||
            (contact.nodeB.name == GameConst.bulletNodeName && contact.nodeA.name == GameConst.targetNodeName)
    }
    
    private func executeTargetHitParticle(contactPoint: SCNVector3) {
        guard let targetHitParticleType = currentWeapon.targetHitParticleType else { return }
        let targetHitParticleNode = createTargetHitParticleNode(type: targetHitParticleType)
        targetHitParticleNode.position = contactPoint
        sceneView.scene.rootNode.addChildNode(targetHitParticleNode)
        targetHitParticleNode.particleSystems?.first?.birthRate = targetHitParticleType.birthRate
        targetHitParticleNode.particleSystems?.first?.loops = false
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
            
            // ターゲットヒット座標に武器に応じたParticleを発火させる
            executeTargetHitParticle(contactPoint: contact.contactPoint)
            
            //ヒットしたという通知をVC経由でsubscribeさせ、statusManagerに伝達する
            _targetHit.accept(Void())
        }
    }
}
