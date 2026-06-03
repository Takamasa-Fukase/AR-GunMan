//
//  ARShootingView.swift
//  ARShooting
//
//  Created by ウルトラ深瀬 on 2026/05/29.
//

import ARKit

public protocol ARShootingDelegate: AnyObject {
    func targetHit()
}

protocol ARShootingViewInterface: AnyObject {
    var sceneView: ARSCNView { get }
    func inject(presenter: ARShootingPresenterInterface)
    func setup(targetCount: Int)
    func showTargetsToRandomPositions(count: Int)
    func runSession()
    func pauseSession()
    func prepareWeaponNodes(
        weaponId: Int,
        weaponNodeInfo: (
            fileName: String,
            parentNodeName: String,
            nodeName: String
        ),
        isGunnerHandShakingAnimationEnabled: Bool,
        particleNodeInfo: (
            fileName: String?,
            nodeName: String?
        )
    )
    func showWeaponNode(of id: Int)
    func removeOtherWeaponNodes(except id: Int)
    func renderWeaponFiring(isRecoilAnimationEnabled: Bool)
    func changeTargetsAppearance(to imageName: String)
}

final class ARShootingView: NSObject, ARShootingViewInterface {
    let sceneView: ARSCNView
    private let originalBulletNode = SceneNodeUtil.originalBulletNode()
    private var loadedWeaponNodeDataList: [LoadedWeaponNodeData] = []
    private var presenter: ARShootingPresenterInterface?
    private weak var delegate: ARShootingDelegate?
    
    init(
        frame: CGRect,
        delegate: ARShootingDelegate
    ) {
        // MEMO: 予めframeを渡して初期化することで、モーダル出現アニメーションの途中時点から既に正しい比率でSceneオブジェクトを表示した状態で一緒にアニメーションさせられるので遷移の見た目が綺麗になる（遷移前に予め表示予定領域のframeが確定している場合）
        sceneView = ARSCNView(frame: frame)
        self.delegate = delegate
        super.init()
    }
    
    func inject(presenter: ARShootingPresenterInterface) {
        self.presenter = presenter
    }
    
    func setup(targetCount: Int) {
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        
        showTargetsToRandomPositions(count: targetCount)
    }
    
    func showTargetsToRandomPositions(count: Int) {
        let originalTargetNode = SceneNodeUtil.originalTargetNode()
        
        DispatchQueue.main.async {
            Array(0..<count).forEach { _ in
                let clonedTargetNode = originalTargetNode.clone()
                clonedTargetNode.position = SceneNodeUtil.getRandomTargetPosition()
                SceneNodeUtil.addBillboardConstraint(clonedTargetNode)
                self.sceneView.scene.rootNode.addChildNode(clonedTargetNode)
            }
        }
    }
    
    func runSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    func pauseSession() {
        sceneView.session.pause()
    }
    
    func prepareWeaponNodes(
        weaponId: Int,
        weaponNodeInfo: (
            fileName: String,
            parentNodeName: String,
            nodeName: String
        ),
        isGunnerHandShakingAnimationEnabled: Bool,
        particleNodeInfo: (
            fileName: String?,
            nodeName: String?
        )
    ) {
        // 武器の親Nodeと武器自体のNodeをロード
        let (weaponParentNode, weaponNode) = createWeaponNode(
            fileName: weaponNodeInfo.fileName,
            parentNodeName: weaponNodeInfo.parentNodeName,
            nodeName: weaponNodeInfo.nodeName
        )
        
        // 武器を持つ手の揺れのアニメーションが有効な場合は描画
        if isGunnerHandShakingAnimationEnabled {
            weaponNode.runAction(SceneAnimationUtil.gunnerHandShakingAnimation)
        }
        
        // Particle情報がある場合はロード
        let targetHitParticleNode: SCNNode? = {
            if let fileName = particleNodeInfo.fileName,
               let nodeName = particleNodeInfo.nodeName
            {
                let particleNode = SceneNodeUtil.loadScnNode(
                    fileName: fileName,
                    nodeName: nodeName
                )
                particleNode.particleSystems?.first?.birthRate = 0
                return particleNode
            } else {
                return nil
            }
        }()
        
        // ロード済みの武器に関するパーツ群を1つの構造体にまとめて配列に保持
        let loadedWeaponNodeData = LoadedWeaponNodeData(
            weaponId: weaponId,
            weaponParentNode: weaponParentNode,
            weaponNode: weaponNode,
            targetHitParticleNode: targetHitParticleNode
        )
        loadedWeaponNodeDataList.append(loadedWeaponNodeData)
    }
    
    func showWeaponNode(of id: Int) {
        guard let loadedWeaponNodeData = loadedWeaponNodeDataList.first(where: { $0.weaponId == id }) else { return }
        sceneView.scene.rootNode.addChildNode(loadedWeaponNodeData.weaponParentNode)
    }
    
    func removeOtherWeaponNodes(except id: Int) {
        loadedWeaponNodeDataList.forEach { loadedWeaponNodeData in
            if loadedWeaponNodeData.weaponId != id {
                loadedWeaponNodeData.weaponParentNode.removeFromParentNode()
            }
        }
    }
    
    func renderWeaponFiring(isRecoilAnimationEnabled: Bool) {
        // 弾の発射アニメーションを描画
        let clonedBulletNode = originalBulletNode.clone()
        clonedBulletNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        sceneView.scene.rootNode.addChildNode(clonedBulletNode)
        clonedBulletNode.runAction(SceneAnimationUtil.bulletShootingAnimation(sceneView.pointOfView)) {
            clonedBulletNode.removeFromParentNode()
        }
        
        // 武器の反動アニメーションを描画
        if isRecoilAnimationEnabled {
            getCurrentDisplayingWeaponNodeData()?.weaponNode.runAction(SceneAnimationUtil.recoilAnimation)
        }
    }
    
    func changeTargetsAppearance(to imageName: String) {
        sceneView.scene.rootNode.childNodes.forEach({ node in
            if node.name == "target" {
                while node.childNode(withName: "torus", recursively: false) != nil {
                    //ドーナツ型の白い線のパーツを削除
                    node.childNode(withName: "torus", recursively: false)?.removeFromParentNode()
                }
            }
            node.childNode(withName: "sphere", recursively: false)?
                .geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName, in: Bundle.module, with: nil)
        })
    }
    
    // MARK: Private Methods
    private func createWeaponNode(
        fileName: String,
        parentNodeName: String,
        nodeName: String
    ) -> (parentNode: SCNNode, weaponNode: SCNNode) {
        let weaponParentNode = SceneNodeUtil.loadScnNode(fileName: fileName, nodeName: parentNodeName)
        SceneNodeUtil.addBillboardConstraint(weaponParentNode)
        weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
        let weaponNode = weaponParentNode.childNode(withName: nodeName, recursively: false) ?? SCNNode()
        return (weaponParentNode, weaponNode)
    }
    
    private func getCurrentDisplayingWeaponNodeData() -> LoadedWeaponNodeData? {
        let currentWeaponId = presenter?.currentWeaponId ?? 0
        return loadedWeaponNodeDataList.first(where: { $0.weaponId == currentWeaponId })
    }
    
    private func renderTargetHitParticle(to position: SCNVector3) {
        if let particleNode = getCurrentDisplayingWeaponNodeData()?.targetHitParticleNode {
            let clonedParticleNode = particleNode.clone()
            clonedParticleNode.position = position
            clonedParticleNode.particleSystems?.first?.birthRate = 300
            clonedParticleNode.particleSystems?.first?.loops = false
            sceneView.scene.rootNode.addChildNode(clonedParticleNode)
        }
    }
}

extension ARShootingView: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        getCurrentDisplayingWeaponNodeData()?.weaponParentNode.position = SceneNodeUtil.getCameraPosition(sceneView)
    }
}

extension ARShootingView: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if contact.nodeA.name == "target" && contact.nodeB.name == "bullet"
            || contact.nodeB.name == "target" && contact.nodeA.name == "bullet" {
            // 弾がターゲットに命中したことを通知
            delegate?.targetHit()
            
            // 着弾時の特殊効果（爆発など）を描画
            renderTargetHitParticle(to: contact.contactPoint)
            
            // 衝突した2つのNode（弾とターゲット）を削除
            contact.nodeA.removeFromParentNode()
            contact.nodeB.removeFromParentNode()
        }
    }
}
