//
//  GameSceneRepository.swift
//  AR-GunMan
//
//  Created by ウルトラ深瀬 on 3/5/24.
//

import Foundation
import ARKit
import SceneKit
import RxSwift
import RxCocoa

protocol GameSceneRepositoryInterface {
    func setupSceneViewAndNodes() -> Observable<Void>
    func getSceneView() -> Observable<UIView>
    func startSession() -> Observable<Void>
    func pauseSession() -> Observable<Void>
    func showWeapon(_ type: WeaponType) -> Observable<WeaponType>
    func fireWeapon() -> Observable<Void>
    func changeTargetsToTaimeisan() -> Observable<Void>
    func getRendererUpdateStream() -> Observable<Void>
    func getCollisionOccurrenceStream() -> Observable<SCNPhysicsContact>
    func moveWeaponToFPSPosition(currentWeapon: WeaponType) -> Observable<Void>
    func checkTargetHit(contact: SCNPhysicsContact) -> Observable<(Bool, SCNPhysicsContact)>
    func removeContactedNodes(nodeA: SCNNode, nodeB: SCNNode) -> Observable<Void>
    func showTargetHitParticleToContactPoint(currentWeapon: WeaponType, contactPoint: SCNVector3) -> Observable<Void>
}

final class GameSceneRepository: NSObject, GameSceneRepositoryInterface {
    private let sceneView = ARSCNView()
    private let rendererUpdatedRelay = PublishRelay<Void>()
    private let collisionOccurredRelay = PublishRelay<SCNPhysicsContact>()
    
    private var originalBazookaHitExplosionParticle = SCNParticleSystem()
    private var pistolParentNode = SCNNode()
    private var bazookaParentNode = SCNNode()

    func setupSceneViewAndNodes() -> Observable<Void> {
        //SceneViewをセットアップ
        SceneViewSettingUtil.setupSceneView(sceneView, sceneViewDelegate: self, physicContactDelegate: self)
        //各武器をセットアップ
        pistolParentNode = setupWeaponNode(type: .pistol)
        bazookaParentNode = setupWeaponNode(type: .bazooka)
        originalBazookaHitExplosionParticle = createOriginalParticleSystem(type: .bazookaExplosion)
        //ターゲットをランダムな位置に配置
        addTarget()
        return Observable.just(Void())
    }

    func getSceneView() -> Observable<UIView> {
        return Observable.just(sceneView)
    }
    
    func startSession() -> Observable<Void> {
        SceneViewSettingUtil.startSession(sceneView)
        return Observable.just(Void())
    }
    
    func pauseSession() -> Observable<Void> {
        SceneViewSettingUtil.pauseSession(sceneView)
        return Observable.just(Void())
    }

    func showWeapon(_ type: WeaponType) -> Observable<WeaponType> {
        switchWeapon(to: type)
        return Observable.just(type)
    }
    
    func fireWeapon() -> Observable<Void> {
        shootBullet()
        pistolNode().runAction(SceneAnimationUtil.shootingMotion())
        return Observable.just(Void())
    }

    func changeTargetsToTaimeisan() -> Observable<Void> {
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
        return Observable.just(Void())
    }

    func getRendererUpdateStream() -> Observable<Void> {
        return rendererUpdatedRelay.asObservable()
    }
    
    func getCollisionOccurrenceStream() -> Observable<SCNPhysicsContact> {
        return collisionOccurredRelay.asObservable()
    }
    
    //現在表示中の武器をラップしている空のオブジェクトを常にカメラと同じPositionに移動させ続ける（それにより武器が常にFPS位置に保たれる）
    func moveWeaponToFPSPosition(currentWeapon: WeaponType) -> Observable<Void> {
        var weaponParentNode: SCNNode {
            switch currentWeapon {
            case .pistol:
                return pistolParentNode
            case .bazooka:
                return bazookaParentNode
            }
        }
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        return Observable.just(Void())
    }

    func checkTargetHit(contact: SCNPhysicsContact) -> Observable<(Bool, SCNPhysicsContact)> {
        let isTargetHit = (contact.nodeA.name == GameConst.bulletNodeName && contact.nodeB.name == GameConst.targetNodeName)
        || (contact.nodeB.name == GameConst.bulletNodeName && contact.nodeA.name == GameConst.targetNodeName)
        return Observable.just((isTargetHit, contact))
    }
    
    func removeContactedNodes(nodeA: SCNNode, nodeB: SCNNode) -> Observable<Void> {
        nodeA.removeFromParentNode()
        nodeB.removeFromParentNode()
        return Observable.just(Void())
    }
    
    func showTargetHitParticleToContactPoint(currentWeapon: WeaponType, contactPoint: SCNVector3) -> Observable<Void> {
        guard let targetHitParticleType = currentWeapon.targetHitParticleType else {
            // TODO: もう少しどうにか綺麗にする
            return Observable.just(Void())
        }
        let targetHitParticleNode = createTargetHitParticleNode(type: targetHitParticleType)
        targetHitParticleNode.position = contactPoint
        sceneView.scene.rootNode.addChildNode(targetHitParticleNode)
        targetHitParticleNode.particleSystems?.first?.birthRate = targetHitParticleType.birthRate
        targetHitParticleNode.particleSystems?.first?.loops = false
        return Observable.just(Void())
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
}

extension GameSceneRepository: ARSCNViewDelegate {
    //常に更新され続けるdelegateメソッド
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        rendererUpdatedRelay.accept(Void())
    }
}

extension GameSceneRepository: SCNPhysicsContactDelegate {
    //衝突検知時に呼ばれる
    //MEMO: - このメソッド内でUIの更新を行いたい場合はmainThreadで行う
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        collisionOccurredRelay.accept(contact)
    }
}

