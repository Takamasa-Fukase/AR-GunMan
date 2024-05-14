//
//  GameSceneController.swift
//  AR-GunMan
//
//  Created by 深瀬 on 2024/05/13.
//

import ARKit
import SceneKit
import RxSwift
import RxCocoa

final class GameSceneController: NSObject {
    private let sceneView: ARSCNView
    private let rendererUpdatedRelay = PublishRelay<Void>()
    private let targetHitRelay = PublishRelay<Void>()
    
    var rendererUpdated: Observable<Void> {
        return rendererUpdatedRelay.asObservable()
    }
    // TODO: 外部にはcollisionOccurredだけ公開して、GameVMでその後を制御させる様にする
    // TODO: BulletNodeにメタ情報としてweaponTypeを付与して、そこから取得したtypeをreturnする様にする
    var targetHit: Observable<Void> {
        return targetHitRelay.asObservable()
    }
    
    private var originalBazookaHitExplosionParticle = SCNParticleSystem()
    private var pistolParentNode = SCNNode()
    private var bazookaParentNode = SCNNode()
    
    init(sceneView: UIView) {
        self.sceneView = sceneView as! ARSCNView
    }

    func setupSceneViewAndNodes() {
        //SceneViewをセットアップ
        SceneViewSettingUtil.setupSceneView(sceneView, sceneViewDelegate: self, physicContactDelegate: self)
        //各武器をセットアップ
        pistolParentNode = setupWeaponNode(type: .pistol)
        bazookaParentNode = setupWeaponNode(type: .bazooka)
        originalBazookaHitExplosionParticle = createOriginalParticleSystem(type: .bazookaExplosion)
    }
    
    // 的ノードをランダムな座標に設置
    func showTargets(count: Int) {
        let originalTargetNode = createOriginalTargetNode()
        Array(0..<count).forEach { index in
            //メモリ節約のためにクローンして使う
            let clonedTargetNode = originalTargetNode.clone()
            clonedTargetNode.position = SceneNodeUtil.getRandomTargetPosition()
            // TODO: nameにindexを混ぜてnode0,node1...みたいにして一意に判別可能にする
            SceneNodeUtil.addBillboardConstraint(clonedTargetNode)
            DispatchQueue.main.async {
                self.sceneView.scene.rootNode.addChildNode(clonedTargetNode)
            }
        }
    }

    func startSession() {
        SceneViewSettingUtil.startSession(sceneView)
    }
    
    func pauseSession() {
        SceneViewSettingUtil.pauseSession(sceneView)
    }

    func showWeapon(_ type: WeaponType) {
        switchWeapon(to: type)
    }
    
    func fireWeapon(_ type: WeaponType) {
        // TODO: weaponTypeを渡してWeaponConstから対象nodeなど取得する様にする（今は実際には弾は共通だが）
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

    //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
    func moveWeaponToFPSPosition(currentWeapon: WeaponType) {
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

    private func setupWeaponNode(type: WeaponType) -> SCNNode {
        let weaponParentNode = SceneNodeUtil.loadScnFile(of: GameConst.getWeaponScnAssetsPath(type), nodeName: "\(type.name)Parent")
        SceneNodeUtil.addBillboardConstraint(weaponParentNode)
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        return weaponParentNode
    }
    
    private func pistolNode() -> SCNNode {
        return pistolParentNode.childNode(withName: WeaponType.pistol.name, recursively: false) ?? SCNNode()
    }
    
    private func switchWeapon(to nextWeapon: WeaponType) {
        SceneNodeUtil.removeOtherWeapon(except: nextWeapon, scnView: sceneView)
        switch nextWeapon {
        case .pistol:
            sceneView.scene.rootNode.addChildNode(pistolParentNode)
            pistolNode().runAction(SceneAnimationUtil.gunnerShakeAnimationNormal())
        case .bazooka:
            sceneView.scene.rootNode.addChildNode(bazookaParentNode)
        }
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
        let clonedBulletNode = GameSceneConst.bulletNode.clone()
        clonedBulletNode.position = SceneNodeUtil.getCameraPosition(sceneView)
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
    
    private func isTargetHit(nodeAName: String, nodeBName: String) -> Bool {
        return (nodeAName == GameConst.bulletNodeName && nodeBName == GameConst.targetNodeName)
        || (nodeAName == GameConst.bulletNodeName && nodeBName == GameConst.targetNodeName)
    }
    
    private func removeContactedNodes(nodeA: SCNNode, nodeB: SCNNode) {
        nodeA.removeFromParentNode()
        nodeB.removeFromParentNode()
    }
    
    private func showTargetHitParticleToContactPoint(currentWeapon: WeaponType, contactPoint: SCNVector3) {
        guard let targetHitParticleType = currentWeapon.targetHitParticleType else { return}
        let targetHitParticleNode = createTargetHitParticleNode(type: targetHitParticleType)
        targetHitParticleNode.position = contactPoint
        sceneView.scene.rootNode.addChildNode(targetHitParticleNode)
        targetHitParticleNode.particleSystems?.first?.birthRate = targetHitParticleType.birthRate
        targetHitParticleNode.particleSystems?.first?.loops = false
    }
}

extension GameSceneController: ARSCNViewDelegate {
    //常に更新され続けるdelegateメソッド
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        rendererUpdatedRelay.accept(Void())
    }
}

extension GameSceneController: SCNPhysicsContactDelegate {
    //衝突検知時に呼ばれる
    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if isTargetHit(nodeAName: contact.nodeA.name, nodeBName: contact.nodeB.name) {
            removeContactedNodes(nodeA: contact.nodeA, nodeB: contact.nodeB)
            // TODO: ここのweaponTypeも後でVMからの指示に含まれたtypeの値に変える
            showTargetHitParticleToContactPoint(currentWeapon: .bazooka, contactPoint: contact.contactPoint)
            targetHitRelay.accept(Void())
        }
    }
}

